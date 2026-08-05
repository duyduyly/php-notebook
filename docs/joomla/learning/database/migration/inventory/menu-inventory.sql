SELECT client_id, menutype, type, published, COUNT(*) AS item_count
FROM joomla3_source.j3_menu
GROUP BY client_id, menutype, type, published
ORDER BY client_id, menutype, type, published;

SELECT id, menutype, title, alias, type, link, parent_id, component_id, access, language, home
FROM joomla3_source.j3_menu
WHERE client_id = 0
ORDER BY menutype, lft;
