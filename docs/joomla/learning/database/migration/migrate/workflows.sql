SET @run_id := (SELECT MAX(id) FROM joomla_migration.migration_runs);

-- Verify the exact Joomla 6 workflow schema before execution.
SET @default_stage_id := (
    SELECT ws.id
    FROM joomla6_target.j6_workflow_stages AS ws
    JOIN joomla6_target.j6_workflows AS w ON w.id = ws.workflow_id
    WHERE w.extension = 'com_content.article' AND w.default = 1 AND ws.default = 1
    ORDER BY ws.id LIMIT 1
);

INSERT INTO joomla6_target.j6_workflow_associations (item_id, stage_id, extension)
SELECT map.target_id, @default_stage_id, 'com_content.article'
FROM joomla_migration.migration_id_map AS map
LEFT JOIN joomla6_target.j6_workflow_associations AS existing
    ON existing.item_id = map.target_id AND existing.extension = 'com_content.article'
WHERE map.run_id = @run_id
  AND map.entity_type = 'content'
  AND map.status = 'migrated'
  AND @default_stage_id IS NOT NULL
  AND existing.item_id IS NULL;
