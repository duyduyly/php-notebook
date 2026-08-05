-- Run after: php migrate.php all

SELECT 'Source category count' AS check_name, COUNT(*) AS result
FROM joomla3_demo.j3_categories;

SELECT 'Target migrated category count' AS check_name, COUNT(*) AS result
FROM joomla6_demo.j6_categories
WHERE id <> 1;

SELECT 'Source article count' AS check_name, COUNT(*) AS result
FROM joomla3_demo.j3_content;

SELECT 'Target article count' AS check_name, COUNT(*) AS result
FROM joomla6_demo.j6_content;

SELECT
    'Category mapping status' AS report_name,
    status,
    COUNT(*) AS total
FROM joomla_migration_demo.migration_category_map
GROUP BY status;

SELECT
    'Article mapping status' AS report_name,
    status,
    COUNT(*) AS total
FROM joomla_migration_demo.migration_content_map
GROUP BY status;

SELECT
    content.id AS target_article_id,
    content.title,
    content.catid
FROM joomla6_demo.j6_content AS content
LEFT JOIN joomla6_demo.j6_categories AS category
    ON category.id = content.catid
WHERE category.id IS NULL;

SELECT
    source_category.id AS source_category_id,
    source_category.title AS source_category_title,
    category_map.target_id AS target_category_id,
    target_category.title AS target_category_title
FROM joomla3_demo.j3_categories AS source_category
LEFT JOIN joomla_migration_demo.migration_category_map AS category_map
    ON category_map.source_id = source_category.id
LEFT JOIN joomla6_demo.j6_categories AS target_category
    ON target_category.id = category_map.target_id
ORDER BY source_category.id;

SELECT
    source_content.id AS source_article_id,
    source_content.title AS source_article_title,
    content_map.target_id AS target_article_id,
    target_content.title AS target_article_title,
    source_content.catid AS source_category_id,
    target_content.catid AS target_category_id
FROM joomla3_demo.j3_content AS source_content
LEFT JOIN joomla_migration_demo.migration_content_map AS content_map
    ON content_map.source_id = source_content.id
LEFT JOIN joomla6_demo.j6_content AS target_content
    ON target_content.id = content_map.target_id
ORDER BY source_content.id;

SELECT
    'Failed category mappings' AS report_name,
    source_id,
    error_message
FROM joomla_migration_demo.migration_category_map
WHERE status = 'failed';

SELECT
    'Failed article mappings' AS report_name,
    source_id,
    error_message
FROM joomla_migration_demo.migration_content_map
WHERE status = 'failed';
