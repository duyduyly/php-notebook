SET @run_id := (SELECT MAX(id) FROM joomla_migration.migration_runs);

INSERT INTO joomla6_target.j6_modules (
    asset_id, title, note, content, ordering, position,
    checked_out, checked_out_time, publish_up, publish_down,
    published, module, access, showtitle, params, client_id, language
)
SELECT
    0, s.title, s.note, s.content, s.ordering,
    CASE s.position WHEN 'top' THEN 'topbar' ELSE s.position END,
    NULL, NULL,
    NULLIF(s.publish_up, '0000-00-00 00:00:00'),
    NULLIF(s.publish_down, '0000-00-00 00:00:00'),
    s.published, s.module, s.access, s.showtitle,
    CASE WHEN JSON_VALID(s.params) THEN s.params ELSE '{}' END,
    0, s.language
FROM joomla3_source.j3_modules AS s
JOIN joomla6_target.j6_extensions AS e
    ON e.type = 'module' AND e.element = s.module AND e.client_id = 0
LEFT JOIN joomla_migration.migration_id_map AS own_map
    ON own_map.run_id = @run_id AND own_map.entity_type = 'module' AND own_map.source_id = s.id
WHERE s.client_id = 0 AND own_map.id IS NULL;

INSERT INTO joomla_migration.migration_id_map (run_id, entity_type, source_id, target_id, status)
SELECT @run_id, 'module', s.id, t.id, 'migrated'
FROM joomla3_source.j3_modules AS s
JOIN joomla6_target.j6_modules AS t
  ON t.client_id = 0 AND t.module = s.module AND t.title = s.title AND t.language = s.language
WHERE s.client_id = 0
ON DUPLICATE KEY UPDATE target_id = VALUES(target_id), status = 'migrated', error_message = NULL;

INSERT INTO joomla6_target.j6_modules_menu (moduleid, menuid)
SELECT module_map.target_id,
       CASE WHEN mm.menuid = 0 THEN 0
            WHEN mm.menuid < 0 THEN -menu_map.target_id
            ELSE menu_map.target_id END
FROM joomla3_source.j3_modules_menu AS mm
JOIN joomla_migration.migration_id_map AS module_map
    ON module_map.run_id = @run_id AND module_map.entity_type = 'module'
   AND module_map.source_id = mm.moduleid
LEFT JOIN joomla_migration.migration_id_map AS menu_map
    ON menu_map.run_id = @run_id AND menu_map.entity_type = 'menu'
   AND menu_map.source_id = ABS(mm.menuid)
WHERE mm.menuid = 0 OR menu_map.target_id IS NOT NULL
ON DUPLICATE KEY UPDATE menuid = VALUES(menuid);
