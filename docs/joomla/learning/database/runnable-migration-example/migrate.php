<?php

declare(strict_types=1);

const TARGET_ROOT_CATEGORY_ID = 1;
const SOURCE_ROOT_CATEGORY_ID = 1;

$configFile = __DIR__ . '/config.php';

if (!is_file($configFile)) {
    fwrite(STDERR, "Missing config.php. Copy config.example.php to config.php and update the credentials.\n");
    exit(1);
}

/** @var array<string, array<string, mixed>> $config */
$config = require $configFile;

try {
    $source = connect($config['source'] ?? []);
    $target = connect($config['target'] ?? []);
    $migration = connect($config['migration'] ?? []);

    $command = $argv[1] ?? 'all';

    if (!in_array($command, ['all', 'categories', 'articles'], true)) {
        throw new InvalidArgumentException(
            'Unknown command. Use: all, categories, or articles.'
        );
    }

    if ($command === 'all' || $command === 'categories') {
        migrateCategories($source, $target, $migration);
    }

    if ($command === 'all' || $command === 'articles') {
        migrateArticles($source, $target, $migration);
    }

    fwrite(STDOUT, "Migration completed successfully.\n");
    exit(0);
} catch (Throwable $exception) {
    fwrite(STDERR, sprintf("Migration failed: %s\n", $exception->getMessage()));
    exit(1);
}

/**
 * @param array<string, mixed> $connectionConfig
 */
function connect(array $connectionConfig): PDO
{
    foreach (['dsn', 'username', 'password'] as $requiredKey) {
        if (!array_key_exists($requiredKey, $connectionConfig)) {
            throw new InvalidArgumentException(
                sprintf('Missing database configuration key: %s', $requiredKey)
            );
        }
    }

    return new PDO(
        (string) $connectionConfig['dsn'],
        (string) $connectionConfig['username'],
        (string) $connectionConfig['password'],
        $connectionConfig['options'] ?? []
    );
}

function migrateCategories(PDO $source, PDO $target, PDO $migration): void
{
    fwrite(STDOUT, "Starting category migration...\n");

    $categories = $source->query(
        'SELECT id, parent_id, title, alias, description, published
         FROM j3_categories
         ORDER BY parent_id, id'
    )->fetchAll();

    $remaining = [];

    foreach ($categories as $category) {
        $remaining[(int) $category['id']] = $category;
    }

    while ($remaining !== []) {
        $progress = false;

        foreach ($remaining as $sourceId => $category) {
            if (isSuccessfullyMapped($migration, 'migration_category_map', $sourceId)) {
                unset($remaining[$sourceId]);
                $progress = true;
                continue;
            }

            $sourceParentId = (int) $category['parent_id'];
            $targetParentId = resolveTargetCategoryId($migration, $sourceParentId);

            if ($targetParentId === null) {
                continue;
            }

            try {
                $target->beginTransaction();

                $statement = $target->prepare(
                    'INSERT INTO j6_categories (
                        parent_id,
                        title,
                        alias,
                        description,
                        published
                    ) VALUES (
                        :parent_id,
                        :title,
                        :alias,
                        :description,
                        :published
                    )'
                );

                $statement->execute([
                    'parent_id' => $targetParentId,
                    'title' => trim((string) $category['title']),
                    'alias' => normalizeAlias((string) $category['alias'], $sourceId),
                    'description' => $category['description'],
                    'published' => (int) $category['published'],
                ]);

                $targetId = (int) $target->lastInsertId();
                saveMapping($migration, 'migration_category_map', $sourceId, $targetId, 'migrated');

                $target->commit();

                fwrite(
                    STDOUT,
                    sprintf("[MIGRATED] category source=%d target=%d\n", $sourceId, $targetId)
                );
            } catch (Throwable $exception) {
                if ($target->inTransaction()) {
                    $target->rollBack();
                }

                saveMapping(
                    $migration,
                    'migration_category_map',
                    $sourceId,
                    null,
                    'failed',
                    $exception->getMessage()
                );

                fwrite(
                    STDERR,
                    sprintf("[FAILED] category source=%d error=%s\n", $sourceId, $exception->getMessage())
                );
            }

            unset($remaining[$sourceId]);
            $progress = true;
        }

        if (!$progress) {
            foreach ($remaining as $sourceId => $category) {
                saveMapping(
                    $migration,
                    'migration_category_map',
                    $sourceId,
                    null,
                    'failed',
                    sprintf('Parent category mapping is missing for source parent ID %d.', $category['parent_id'])
                );
            }

            throw new RuntimeException('Category migration stopped because unresolved parent mappings remain.');
        }
    }

    fwrite(STDOUT, "Category migration completed.\n");
}

function migrateArticles(PDO $source, PDO $target, PDO $migration): void
{
    fwrite(STDOUT, "Starting article migration...\n");

    $articles = $source->query(
        'SELECT id, title, alias, introtext, fulltext, catid, state, created, images, metadata
         FROM j3_content
         ORDER BY id'
    )->fetchAll();

    foreach ($articles as $article) {
        $sourceId = (int) $article['id'];

        if (isSuccessfullyMapped($migration, 'migration_content_map', $sourceId)) {
            continue;
        }

        try {
            $targetCategoryId = resolveTargetCategoryId($migration, (int) $article['catid']);

            if ($targetCategoryId === null) {
                throw new RuntimeException(
                    sprintf('Category mapping is missing for source category ID %d.', $article['catid'])
                );
            }

            $target->beginTransaction();

            $statement = $target->prepare(
                'INSERT INTO j6_content (
                    title,
                    alias,
                    introtext,
                    fulltext,
                    catid,
                    state,
                    created,
                    images,
                    metadata
                ) VALUES (
                    :title,
                    :alias,
                    :introtext,
                    :fulltext,
                    :catid,
                    :state,
                    :created,
                    :images,
                    :metadata
                )'
            );

            $statement->execute([
                'title' => trim((string) $article['title']),
                'alias' => normalizeAlias((string) $article['alias'], $sourceId),
                'introtext' => $article['introtext'],
                'fulltext' => $article['fulltext'],
                'catid' => $targetCategoryId,
                'state' => (int) $article['state'],
                'created' => normalizeDate($article['created']),
                'images' => normalizeJsonObject($article['images']),
                'metadata' => normalizeJsonObject($article['metadata']),
            ]);

            $targetId = (int) $target->lastInsertId();
            saveMapping($migration, 'migration_content_map', $sourceId, $targetId, 'migrated');

            $target->commit();

            fwrite(
                STDOUT,
                sprintf("[MIGRATED] article source=%d target=%d\n", $sourceId, $targetId)
            );
        } catch (Throwable $exception) {
            if ($target->inTransaction()) {
                $target->rollBack();
            }

            saveMapping(
                $migration,
                'migration_content_map',
                $sourceId,
                null,
                'failed',
                $exception->getMessage()
            );

            fwrite(
                STDERR,
                sprintf("[FAILED] article source=%d error=%s\n", $sourceId, $exception->getMessage())
            );
        }
    }

    fwrite(STDOUT, "Article migration completed.\n");
}

function resolveTargetCategoryId(PDO $migration, int $sourceCategoryId): ?int
{
    if ($sourceCategoryId === SOURCE_ROOT_CATEGORY_ID) {
        return TARGET_ROOT_CATEGORY_ID;
    }

    $statement = $migration->prepare(
        'SELECT target_id
         FROM migration_category_map
         WHERE source_id = :source_id
           AND status = :status'
    );

    $statement->execute([
        'source_id' => $sourceCategoryId,
        'status' => 'migrated',
    ]);

    $targetId = $statement->fetchColumn();

    return $targetId === false ? null : (int) $targetId;
}

function isSuccessfullyMapped(PDO $migration, string $table, int $sourceId): bool
{
    assertAllowedMappingTable($table);

    $statement = $migration->prepare(
        sprintf(
            'SELECT 1 FROM %s WHERE source_id = :source_id AND status = :status',
            $table
        )
    );

    $statement->execute([
        'source_id' => $sourceId,
        'status' => 'migrated',
    ]);

    return $statement->fetchColumn() !== false;
}

function saveMapping(
    PDO $migration,
    string $table,
    int $sourceId,
    ?int $targetId,
    string $status,
    ?string $errorMessage = null
): void {
    assertAllowedMappingTable($table);

    $statement = $migration->prepare(
        sprintf(
            'INSERT INTO %s (
                source_id,
                target_id,
                status,
                error_message,
                migrated_at
            ) VALUES (
                :source_id,
                :target_id,
                :status,
                :error_message,
                :migrated_at
            )
            ON DUPLICATE KEY UPDATE
                target_id = VALUES(target_id),
                status = VALUES(status),
                error_message = VALUES(error_message),
                migrated_at = VALUES(migrated_at)',
            $table
        )
    );

    $statement->execute([
        'source_id' => $sourceId,
        'target_id' => $targetId,
        'status' => $status,
        'error_message' => $errorMessage,
        'migrated_at' => $status === 'migrated' ? date('Y-m-d H:i:s') : null,
    ]);
}

function assertAllowedMappingTable(string $table): void
{
    if (!in_array($table, ['migration_category_map', 'migration_content_map'], true)) {
        throw new InvalidArgumentException('Unsupported mapping table.');
    }
}

function normalizeAlias(string $alias, int $sourceId): string
{
    $alias = trim(strtolower($alias));
    $alias = preg_replace('/[^a-z0-9-]+/', '-', $alias) ?? '';
    $alias = trim($alias, '-');

    return $alias !== '' ? $alias : sprintf('migrated-%d', $sourceId);
}

function normalizeDate(mixed $value): ?string
{
    if (!is_string($value)) {
        return null;
    }

    $value = trim($value);

    if ($value === '' || $value === '0000-00-00' || $value === '0000-00-00 00:00:00') {
        return null;
    }

    $date = DateTimeImmutable::createFromFormat('Y-m-d H:i:s', $value);

    if ($date === false) {
        throw new InvalidArgumentException(sprintf('Invalid date value: %s', $value));
    }

    return $date->format('Y-m-d H:i:s');
}

function normalizeJsonObject(mixed $value): string
{
    if (!is_string($value) || trim($value) === '') {
        return '{}';
    }

    $decoded = json_decode($value, true, 512, JSON_THROW_ON_ERROR);

    if (!is_array($decoded)) {
        throw new InvalidArgumentException('The JSON value must decode to an object or array.');
    }

    return json_encode(
        $decoded,
        JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE
    );
}
