SELECT extension, COUNT(*) AS category_count, MAX(level) AS maximum_level
FROM joomla3_source.j3_categories
GROUP BY extension
ORDER BY extension;

SELECT id, parent_id, extension, title, alias, path, level, published, access, language
FROM joomla3_source.j3_categories
ORDER BY extension, lft;
