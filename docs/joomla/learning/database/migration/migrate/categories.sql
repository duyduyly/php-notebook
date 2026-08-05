SET @run_id := (SELECT MAX(id) FROM joomla_migration.migration_runs);

-- Repeat until every approved parent mapping is resolved.
INSERT INTO joomla6_target.j6_categories (
    asset_id, parent_id, lft, rgt, level, path,
    extension, title, alias, description, published,
    access, params, metadata, language
)
SELECT
    0,
    COALESCE(parent_map.target_id, 1),
    0, 0, 0, '',
    s.extension, s.title, s.alias, s.description, s.published,
    s.access,
    CASE WHEN JSON_VALID(s.params) THEN s.params ELSE '{}' END,
    CASE WHEN JSON_VALID(s.metadata) THEN s.metadata ELSE '{}' END,
    s.language
FROM joomla3_source.j3_categories AS s
LEFT JOIN joomla_migration.migration_id_map AS own_map
    ON own_map.run_id = @run_id AND own_map.entity_type = 'category' AND own_map.source_id = s.id
LEFT JOIN joomla_migration.migration_id_map AS parent_map
    ON parent_map.run_id = @run_id AND parent_map.entity_type = 'category' AND parent_map.source_id = s.parent_id
WHERE own_map.id IS NULL
  AND s.id > 1
  AND (s.parent_id IN (0, 1) OR parent_map.target_id IS NOT NULL)
ORDER BY s.level, s.lft;

INSERT INTO joomla_migration.migration_id_map (run_id, entity_type, source_id, target_id, status)
SELECT @run_id, 'category', s.id, t.id, 'migrated'
FROM joomla3_source.j3_categories AS s
JOIN joomla6_target.j6_categories AS t
  ON t.extension = s.extension AND t.title = s.title AND t.alias = s.alias AND t.language = s.language
ON DUPLICATE KEY UPDATE target_id = VALUES(target_id), status = 'migrated', error_message = NULL;

-- Rebuild lft, rgt, level, path, and ACL assets after import.
