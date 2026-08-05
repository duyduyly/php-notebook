SELECT client_id, module, position, published, COUNT(*) AS module_count
FROM joomla3_source.j3_modules
GROUP BY client_id, module, position, published
ORDER BY client_id, module, position;

SELECT moduleid,
       SUM(menuid = 0) AS all_pages_rows,
       SUM(menuid > 0) AS included_menu_rows,
       SUM(menuid < 0) AS excluded_menu_rows
FROM joomla3_source.j3_modules_menu
GROUP BY moduleid
ORDER BY moduleid;
