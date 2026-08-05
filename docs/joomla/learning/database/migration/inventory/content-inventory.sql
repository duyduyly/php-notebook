SELECT
    COUNT(*) AS total_articles,
    SUM(state = 1) AS published_articles,
    SUM(state = 0) AS unpublished_articles,
    SUM(state = -2) AS trashed_articles,
    COUNT(DISTINCT catid) AS referenced_categories,
    COUNT(DISTINCT created_by) AS referenced_authors,
    MIN(created) AS oldest_created,
    MAX(created) AS newest_created
FROM joomla3_source.j3_content;

SELECT language, state, COUNT(*) AS article_count
FROM joomla3_source.j3_content
GROUP BY language, state
ORDER BY language, state;
