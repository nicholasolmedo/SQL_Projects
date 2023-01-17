SELECT*FROM tester.comments;

SELECT*FROM tester.videos_stats;

# What are the most commented-on and liked videos?
SELECT title, comments
FROM videos_stats
ORDER BY comments DESC;

SELECT title, likes
FROM videos_stats
ORDER BY likes DESC;

# What is the total number of views/likes by video category?
SELECT SUM(views), keyword
FROM videos_stats
GROUP BY keyword
ORDER BY SUM(views) DESC;

SELECT SUM(likes), keyword
FROM videos_stats
GROUP BY keyword
ORDER BY SUM(likes) DESC;

# What are the most-liked comments?
SELECT Likes, Comment_
FROM comments
ORDER BY Likes DESC;

# What is the ratio of views:likes for each video? For each category?
SELECT title, views/likes 
FROM videos_stats;

SELECT keyword, SUM(views)/SUM(likes) AS Ratio
FROM videos_stats
GROUP BY keyword
ORDER BY Ratio DESC;

SELECT AVG(Sentiment), keyword FROM
(
SELECT comments.Sentiment, videos_stats.keyword 
FROM comments
INNER JOIN videos_stats ON comments.`VIDEO ID`=videos_stats.video_id
) AS SUBQUERY
GROUP BY keyword;

SELECT comments.Sentiment, videos_stats.keyword 
FROM comments
INNER JOIN videos_stats ON comments.`VIDEO ID`=videos_stats.video_id;

# How often do company names appear in each keyword category?
SELECT title, keyword
FROM videos_stats
WHERE title LIKE '%Apple%';

SELECT COUNT(title), keyword
FROM videos_stats
WHERE title LIKE '%Apple%'
GROUP BY keyword;

SELECT COUNT(title), keyword
FROM videos_stats
WHERE title LIKE '%Amazon%'
GROUP BY keyword;

SELECT COUNT(title), keyword
FROM videos_stats
WHERE title LIKE '%Google%'
GROUP BY keyword;

SELECT COUNT(title), keyword
FROM videos_stats
WHERE title LIKE '%Car%'
GROUP BY keyword
