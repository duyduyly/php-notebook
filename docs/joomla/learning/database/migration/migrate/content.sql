SET @run_id := (SELECT MAX(id) FROM joomla_migration.migration_runs);

INSERT INTO joomla6_target.j6_content (
    asset_id, title, alias, introtext, fulltext, state,
    catid, created, created_by, created_by_alias,
    modified, modified_by, checked_out, checked_out_time,
    publish_up, publish_down, images, urls, attribs,
    version, ordering, metakey, metadesc, access, hits,
    metadata, featured, language, note
)
SELECT
    0, s.title, s.alias, s.introtext, s.fulltext, s.state,
    category_map.target_id,
    NULLIF(s.created, '0000-00-00 00:00:00'),
    COALESCE(user_map.target_id, 0), s.created_by_alias,
    NULLIF(s.modified, '0000-00-00 00:00:00'),
    COALESCE(modifier_map.target_id, 0), NULL, NULL,
    NULLIF(s.publish_up, '0000-00-00 00:00:00'),
    NULLIF(s.publish_down, '0000-00-00 00:00:00'),
    CASE WHEN JSON_VALID(s.images) THEN s.images ELSE '{}' END,
    CASE WHEN JSON_VALID(s.urls) THEN s.urls ELSE '{}' END,
    CASE WHEN JSON_VALID(s.attribs) THEN s.attribs ELSE '{}' END,
    s.version, s.ordering, s.metakey, s.metadesc, s.access, s.hits,
    CASE WHEN JSON_VALID(s.metadata) THEN s.metadata ELSE '{}' END,
    s.featured, s.language, s.note
FROM joomla3_source.j3_content AS s
JOIN joomla_migration.migration_id_map AS category_map
    ON category_map.run_id = @run_id AND category_map.entity_type = 'category'
   AND category_map.source_id = s.catid AND category_map.status = 'migrated'
LEFT JOIN joomla_migration.migration_id_map AS user_map
    ON user_map.run_id = @run_id AND user_map.entity_type = 'user' AND user_map.source_id = s.created_by
LEFT JOIN joomla_migration.migration_id_map AS modifier_map
    ON modifier_map.run_id = @run_id AND modifier_map.entity_type = 'user' AND modifier_map.source_id = s.modified_by
LEFT JOIN joomla_migration.migration_id_map AS own_map
    ON own_map.run_id = @run_id AND own_map.entity_type = 'content' AND own_map.source_id = s.id
WHERE own_map.id IS NULL;

INSERT INTO joomla_migration.migration_id_map (run_id, entity_type, source_id, target_id, status)
SELECT @run_id, 'content', s.id, t.id, 'migrated'
FROM joomla3_source.j3_content AS s
JOIN joomla_migration.migration_id_map AS cm
    ON cm.run_id = @run_id AND cm.entity_type = 'category' AND cm.source_id = s.catid
JOIN joomla6_target.j6_content AS t
    ON t.catid = cm.target_id AND t.alias = s.alias AND t.language = s.language
ON DUPLICATE KEY UPDATE target_id = VALUES(target_id), status = 'migrated', error_message = NULL;
