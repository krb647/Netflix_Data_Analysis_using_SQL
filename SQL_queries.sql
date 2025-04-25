DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

SELECT * FROM netflix;

--Business problems

--1. Count the Number of Movies vs TV Shows

SELECT type,COUNT(*) 
FROM netflix
GROUP BY type;

--2. Find the Most Common Rating for Movies and TV Shows

SELECT type,rating 
FROM 
(SELECT 
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
FROM netflix
GROUP BY 1,2
ORDER BY 1,3 DESC)
WHERE ranking = 1;

--3. List All Movies Released in a Specific Year

SELECT * FROM netflix
WHERE 
	type = 'Movie' AND
	release_year = 2020;

--4. Find the Top 5 Countries with the Most Content on Netflix

SELECT UNNEST(STRING_TO_ARRAY(trim(lower(country)),',')) AS Country,
	   COUNT(*) AS Total_Content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--5. Identify the Longest Movie

SELECT * 
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration,' ',1)::INT DESC
LIMIT 1;

--6. Find Content Added in the Last 5 Years

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

--7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT * FROM 
(SELECT *, UNNEST(STRING_TO_ARRAY(director,',')) AS director_name
FROM netflix)
WHERE director_name = 'Rajiv Chilaka';

--8. List All TV Shows with More Than 5 Seasons

SELECT * FROM netflix
WHERE type = 'TV Show'
AND SPLIT_PART(duration,' ',1)::INT > 5;

--9. Count the Number of Content Items in Each Genre

SELECT UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
	   COUNT(*) AS total_content
FROM netflix
GROUP BY genre;

--10. Find each year and the average numbers of content release in India on netflix.

SELECT EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) AS year,
	   COUNT(*) AS total_content,
	   ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric*100,2) AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 3 DESC;

--11. List All Movies that are Documentaries

SELECT * 
FROM netflix
WHERE listed_in ILIKE '%documentaries%';

--12. Find All Content Without a Director

SELECT * 
FROM netflix
WHERE director IS NULL;

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT * FROM netflix
WHERE casts ILIKE '%Salman Khan%'
	  AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;

--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT UNNEST(STRING_TO_ARRAY(casts,',')) AS top_actors,
	   COUNT(*) AS number_of_movies
FROM netflix
WHERE country = 'India'
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 10;

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

WITH new_table AS
(
SELECT *,
	   CASE 
	   WHEN description ILIKE '%kill%' OR description ILIKE '%violence%'
	   THEN 'Bad_content' 
	   ELSE 'Good_content' 
	   END AS category
FROM netflix
)
SELECT category, COUNT(*) AS total_content
FROM new_table
GROUP BY 1;









