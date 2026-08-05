SET @run_id := (SELECT MAX(id) FROM joomla_migration.migration_runs);

-- Repeat until every approved parent mapping is resolved.
INSERT INTO joomla6_target.j6_tags (
    parent_id, lft, rgt, level, path, title, alias,
    note, description, published, checked_out,
    checked_out_time, access, params, metadata, language
)
SELECT
    COALESCE(parent_map.target_id, 1), 0, 0, 0, '',
    s.title, s.alias, s.note, s.description, s.published,
    NULL, NULL, s.access,
    CASE WHEN JSON_VALID(s.params) THEN s.params ELSE '{}' END,
    CASE WHEN JSON_VALID(s.metadata) THEN s.metadata ELSE '{}' END,
    s.language
FROM joomla3_source.j3_tags AS s
LEFT JOIN joomla_migration.migration_id_map AS own_map
    ON own_map.run_id = @run_id AND own_map.entity_type = 'tag' AND own_map.source_id = s.id
LEFT JOIN joomla_migration.migration_id_map AS parent_map
    ON parent_map.run_id = @run_id AND parent_map.entity_type = 'tag' AND parent_map.source_id = s.parent_id
WHERE own_map.id IS NULL AND s.id > 1
  AND (s.parent_id IN (0, 1) OR parent_map.target_id IS NOT NULL)
ORDER BY s.level, s.lft;

INSERT INTO joomla_migration.migration_id_map (run_id, entity_type, source_id, target_id, status)
SELECT @run_id, 'tag', s.id, t.id, 'migrated'
FROM joomla3_source.j3_tags AS s
JOIN joomla6_target.j6_tags AS t ON t.alias = s.alias AND t.language = s.language
ON DUPLICATE KEY UPDATE target_id = VALUES(target_id), status = 'migrated', error_message = NULL;

-- Add content-item tag mappings after confirming target content type identities.
