SELECT c.id, c.title, c.catid
FROM joomla6_target.j6_content AS c
LEFT JOIN joomla6_target.j6_categories AS cat ON cat.id = c.catid
WHERE cat.id IS NULL;

SELECT mm.moduleid, mm.menuid
FROM joomla6_target.j6_modules_menu AS mm
LEFT JOIN joomla6_target.j6_modules AS mo ON mo.id = mm.moduleid
LEFT JOIN joomla6_target.j6_menu AS me ON me.id = ABS(mm.menuid)
WHERE mo.id IS NULL OR (mm.menuid <> 0 AND me.id IS NULL);

SELECT wa.item_id, wa.stage_id
FROM joomla6_target.j6_workflow_associations AS wa
LEFT JOIN joomla6_target.j6_content AS c ON c.id = wa.item_id
LEFT JOIN joomla6_target.j6_workflow_stages AS ws ON ws.id = wa.stage_id
WHERE wa.extension = 'com_content.article'
  AND (c.id IS NULL OR ws.id IS NULL);
