SET @run_id := (SELECT MAX(id) FROM joomla_migration.migration_runs);

-- Install every required Joomla 6 field plugin before migrating definitions.
INSERT INTO joomla6_target.j6_fields_groups (
    asset_id, context, title, note, description,
    state, checked_out, checked_out_time, ordering,
    params, language, created_user_id, modified_by
)
SELECT
    0, s.context, s.title, s.note, s.description,
    s.state, NULL, NULL, s.ordering,
    CASE WHEN JSON_VALID(s.params) THEN s.params ELSE '{}' END,
    s.language,
    COALESCE(creator_map.target_id, 0),
    COALESCE(modifier_map.target_id, 0)
FROM joomla3_source.j3_fields_groups AS s
LEFT JOIN joomla_migration.migration_id_map AS creator_map
    ON creator_map.run_id = @run_id AND creator_map.entity_type = 'user'
   AND creator_map.source_id = s.created_user_id
LEFT JOIN joomla_migration.migration_id_map AS modifier_map
    ON modifier_map.run_id = @run_id AND modifier_map.entity_type = 'user'
   AND modifier_map.source_id = s.modified_by
WHERE NOT EXISTS (
    SELECT 1 FROM joomla6_target.j6_fields_groups AS t
    WHERE t.context = s.context AND t.title = s.title AND t.language = s.language
);

-- Field definitions and values require mappings for group_id, field_id, and item_id.
