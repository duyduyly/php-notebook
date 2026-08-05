SET @run_id := (SELECT MAX(id) FROM joomla_migration.migration_runs);

SELECT
    map.source_id,
    map.target_id,
    MD5(CONCAT_WS('|', s.title, s.alias, COALESCE(s.introtext, ''), COALESCE(s.fulltext, ''))) AS source_hash,
    MD5(CONCAT_WS('|', t.title, t.alias, COALESCE(t.introtext, ''), COALESCE(t.fulltext, ''))) AS target_hash,
    CASE
        WHEN MD5(CONCAT_WS('|', s.title, s.alias, COALESCE(s.introtext, ''), COALESCE(s.fulltext, '')))
           = MD5(CONCAT_WS('|', t.title, t.alias, COALESCE(t.introtext, ''), COALESCE(t.fulltext, '')))
        THEN 'MATCH' ELSE 'DIFFERENT'
    END AS checksum_status
FROM joomla_migration.migration_id_map AS map
JOIN joomla3_source.j3_content AS s ON s.id = map.source_id
JOIN joomla6_target.j6_content AS t ON t.id = map.target_id
WHERE map.run_id = @run_id
  AND map.entity_type = 'content'
  AND map.status = 'migrated'
ORDER BY map.source_id;
