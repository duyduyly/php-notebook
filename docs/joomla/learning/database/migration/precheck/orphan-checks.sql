SELECT c.id, c.title, c.catid
FROM joomla3_source.j3_content AS c
LEFT JOIN joomla3_source.j3_categories AS cat ON cat.id = c.catid
WHERE cat.id IS NULL;

SELECT c.id, c.title, c.created_by
FROM joomla3_source.j3_content AS c
LEFT JOIN joomla3_source.j3_users AS u ON u.id = c.created_by
WHERE c.created_by <> 0 AND u.id IS NULL;

SELECT m.id, m.title, m.parent_id
FROM joomla3_source.j3_menu AS m
LEFT JOIN joomla3_source.j3_menu AS p ON p.id = m.parent_id
WHERE m.client_id = 0 AND m.parent_id NOT IN (0, 1) AND p.id IS NULL;

SELECT mm.moduleid, mm.menuid
FROM joomla3_source.j3_modules_menu AS mm
LEFT JOIN joomla3_source.j3_modules AS mo ON mo.id = mm.moduleid
LEFT JOIN joomla3_source.j3_menu AS me ON me.id = ABS(mm.menuid)
WHERE mo.id IS NULL OR (mm.menuid <> 0 AND me.id IS NULL);
