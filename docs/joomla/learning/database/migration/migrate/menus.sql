SET @run_id := (SELECT MAX(id) FROM joomla_migration.migration_runs);

INSERT INTO joomla6_target.j6_menu_types (menutype, title, description, client_id)
SELECT s.menutype, s.title, s.description, 0
FROM joomla3_source.j3_menu_types AS s
WHERE s.client_id = 0
  AND NOT EXISTS (
      SELECT 1 FROM joomla6_target.j6_menu_types AS t
      WHERE t.menutype = s.menutype AND t.client_id = 0
  );

-- Example supports frontend component menu items. Extend link rewriting per view.
INSERT INTO joomla6_target.j6_menu (
    menutype, title, alias, note, path, link, type,
    published, parent_id, level, component_id,
    checked_out, checked_out_time, browserNav,
    access, img, template_style_id, params,
    lft, rgt, home, language, client_id
)
SELECT
    s.menutype, s.title, s.alias, s.note, '',
    CASE
        WHEN s.link LIKE 'index.php?option=com_content&view=article&id=%'
        THEN CONCAT('index.php?option=com_content&view=article&id=', content_map.target_id)
        ELSE s.link
    END,
    s.type, s.published, COALESCE(parent_map.target_id, 1), 0,
    target_extension.extension_id, NULL, NULL, s.browserNav,
    s.access, s.img, 0,
    CASE WHEN JSON_VALID(s.params) THEN s.params ELSE '{}' END,
    0, 0, s.home, s.language, 0
FROM joomla3_source.j3_menu AS s
JOIN joomla3_source.j3_extensions AS source_extension ON source_extension.extension_id = s.component_id
JOIN joomla6_target.j6_extensions AS target_extension
    ON target_extension.type = source_extension.type
   AND target_extension.element = source_extension.element
   AND target_extension.folder = source_extension.folder
   AND target_extension.client_id = source_extension.client_id
LEFT JOIN joomla_migration.migration_id_map AS parent_map
    ON parent_map.run_id = @run_id AND parent_map.entity_type = 'menu' AND parent_map.source_id = s.parent_id
LEFT JOIN joomla_migration.migration_id_map AS content_map
    ON content_map.run_id = @run_id AND content_map.entity_type = 'content'
   AND content_map.source_id = CAST(SUBSTRING_INDEX(s.link, 'id=', -1) AS UNSIGNED)
LEFT JOIN joomla_migration.migration_id_map AS own_map
    ON own_map.run_id = @run_id AND own_map.entity_type = 'menu' AND own_map.source_id = s.id
WHERE s.client_id = 0 AND own_map.id IS NULL
  AND (s.parent_id IN (0, 1) OR parent_map.target_id IS NOT NULL)
ORDER BY s.level, s.lft;

INSERT INTO joomla_migration.migration_id_map (run_id, entity_type, source_id, target_id, status)
SELECT @run_id, 'menu', s.id, t.id, 'migrated'
FROM joomla3_source.j3_menu AS s
JOIN joomla6_target.j6_menu AS t
  ON t.client_id = 0 AND t.menutype = s.menutype AND t.alias = s.alias AND t.language = s.language
WHERE s.client_id = 0
ON DUPLICATE KEY UPDATE target_id = VALUES(target_id), status = 'migrated', error_message = NULL;
