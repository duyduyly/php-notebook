SELECT id, 'content.images' AS field_name, images AS invalid_value
FROM joomla3_source.j3_content
WHERE images IS NOT NULL AND images <> '' AND JSON_VALID(images) = 0
UNION ALL
SELECT id, 'content.urls', urls FROM joomla3_source.j3_content
WHERE urls IS NOT NULL AND urls <> '' AND JSON_VALID(urls) = 0
UNION ALL
SELECT id, 'content.attribs', attribs FROM joomla3_source.j3_content
WHERE attribs IS NOT NULL AND attribs <> '' AND JSON_VALID(attribs) = 0
UNION ALL
SELECT id, 'content.metadata', metadata FROM joomla3_source.j3_content
WHERE metadata IS NOT NULL AND metadata <> '' AND JSON_VALID(metadata) = 0
UNION ALL
SELECT id, 'modules.params', params FROM joomla3_source.j3_modules
WHERE params IS NOT NULL AND params <> '' AND JSON_VALID(params) = 0;
