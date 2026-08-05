SELECT 'categories' AS tree_name, id, parent_id, lft, rgt, level, path
FROM joomla3_source.j3_categories
WHERE lft >= rgt OR lft < 0 OR rgt < 0
UNION ALL
SELECT 'menu', id, parent_id, lft, rgt, level, path
FROM joomla3_source.j3_menu
WHERE lft >= rgt OR lft < 0 OR rgt < 0
UNION ALL
SELECT 'tags', id, parent_id, lft, rgt, level, path
FROM joomla3_source.j3_tags
WHERE lft >= rgt OR lft < 0 OR rgt < 0;

SELECT boundary_value, COUNT(*) AS duplicate_count
FROM (
    SELECT lft AS boundary_value FROM joomla3_source.j3_categories
    UNION ALL
    SELECT rgt FROM joomla3_source.j3_categories
) AS boundaries
GROUP BY boundary_value
HAVING COUNT(*) > 1;
