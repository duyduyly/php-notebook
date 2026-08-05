SELECT catid, language, alias, COUNT(*) AS duplicate_count
FROM joomla3_source.j3_content
WHERE alias <> ''
GROUP BY catid, language, alias
HAVING COUNT(*) > 1;

SELECT parent_id, extension, language, alias, COUNT(*) AS duplicate_count
FROM joomla3_source.j3_categories
WHERE alias <> ''
GROUP BY parent_id, extension, language, alias
HAVING COUNT(*) > 1;

SELECT menutype, parent_id, language, alias, COUNT(*) AS duplicate_count
FROM joomla3_source.j3_menu
WHERE client_id = 0 AND alias <> ''
GROUP BY menutype, parent_id, language, alias
HAVING COUNT(*) > 1;
