SET @run_id := (SELECT MAX(id) FROM joomla_migration.migration_runs);

INSERT INTO joomla6_target.j6_users (
    name, username, email, password, block, sendEmail,
    registerDate, lastvisitDate, activation, params
)
SELECT
    s.name, s.username, s.email, s.password, s.block, s.sendEmail,
    NULLIF(s.registerDate, '0000-00-00 00:00:00'),
    NULLIF(s.lastvisitDate, '0000-00-00 00:00:00'),
    '',
    CASE WHEN JSON_VALID(s.params) THEN s.params ELSE '{}' END
FROM joomla3_source.j3_users AS s
LEFT JOIN joomla_migration.migration_id_map AS map
    ON map.run_id = @run_id AND map.entity_type = 'user' AND map.source_id = s.id
WHERE map.id IS NULL
  AND NOT EXISTS (
      SELECT 1 FROM joomla6_target.j6_users AS t
      WHERE t.username = s.username OR t.email = s.email
  );

INSERT INTO joomla_migration.migration_id_map (run_id, entity_type, source_id, target_id, status)
SELECT @run_id, 'user', s.id, t.id, 'migrated'
FROM joomla3_source.j3_users AS s
JOIN joomla6_target.j6_users AS t ON t.username = s.username AND t.email = s.email
ON DUPLICATE KEY UPDATE target_id = VALUES(target_id), status = 'migrated', error_message = NULL;

-- Map user groups by business meaning, not raw Joomla 3 IDs.
