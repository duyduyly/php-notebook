SET @run_id := (SELECT MAX(id) FROM joomla_migration.migration_runs);

START TRANSACTION;

DELETE mm
FROM joomla6_target.j6_modules_menu AS mm
JOIN joomla_migration.migration_id_map AS map
  ON map.run_id = @run_id AND map.entity_type = 'module' AND map.target_id = mm.moduleid;

DELETE t FROM joomla6_target.j6_modules AS t
JOIN joomla_migration.migration_id_map AS map
  ON map.run_id = @run_id AND map.entity_type = 'module' AND map.target_id = t.id;

DELETE t FROM joomla6_target.j6_menu AS t
JOIN joomla_migration.migration_id_map AS map
  ON map.run_id = @run_id AND map.entity_type = 'menu' AND map.target_id = t.id;

DELETE wa FROM joomla6_target.j6_workflow_associations AS wa
JOIN joomla_migration.migration_id_map AS map
  ON map.run_id = @run_id AND map.entity_type = 'content' AND map.target_id = wa.item_id
WHERE wa.extension = 'com_content.article';

DELETE t FROM joomla6_target.j6_content AS t
JOIN joomla_migration.migration_id_map AS map
  ON map.run_id = @run_id AND map.entity_type = 'content' AND map.target_id = t.id;

DELETE t FROM joomla6_target.j6_tags AS t
JOIN joomla_migration.migration_id_map AS map
  ON map.run_id = @run_id AND map.entity_type = 'tag' AND map.target_id = t.id
ORDER BY t.level DESC;

DELETE t FROM joomla6_target.j6_categories AS t
JOIN joomla_migration.migration_id_map AS map
  ON map.run_id = @run_id AND map.entity_type = 'category' AND map.target_id = t.id
ORDER BY t.level DESC;

-- Users are intentionally not deleted automatically.
UPDATE joomla_migration.migration_runs
SET status = 'rolled_back', completed_at = NOW()
WHERE id = @run_id;

COMMIT;

-- Production rollback should restore the pre-migration target snapshot.
