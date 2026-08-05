SET @run_id := (SELECT MAX(id) FROM joomla_migration.migration_runs);

SELECT entity_type, status, COUNT(*) AS record_count
FROM joomla_migration.migration_id_map
WHERE run_id = @run_id
GROUP BY entity_type, status
ORDER BY entity_type, status;

SELECT
    (SELECT COUNT(*) FROM joomla3_source.j3_content) AS source_articles,
    (SELECT COUNT(*) FROM joomla_migration.migration_id_map
      WHERE run_id = @run_id AND entity_type = 'content' AND status = 'migrated') AS mapped_articles,
    (SELECT COUNT(*) FROM joomla6_target.j6_content) AS target_articles;
