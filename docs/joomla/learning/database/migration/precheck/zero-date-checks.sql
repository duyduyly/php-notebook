SELECT id, 'created' AS field_name, created AS invalid_value
FROM joomla3_source.j3_content
WHERE created IN ('0000-00-00', '0000-00-00 00:00:00')
UNION ALL
SELECT id, 'modified', modified FROM joomla3_source.j3_content
WHERE modified IN ('0000-00-00', '0000-00-00 00:00:00')
UNION ALL
SELECT id, 'publish_up', publish_up FROM joomla3_source.j3_content
WHERE publish_up IN ('0000-00-00', '0000-00-00 00:00:00')
UNION ALL
SELECT id, 'publish_down', publish_down FROM joomla3_source.j3_content
WHERE publish_down IN ('0000-00-00', '0000-00-00 00:00:00');
