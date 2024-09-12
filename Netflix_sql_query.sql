-- SCHEMAS of Netflix

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);


-- To see everything data on the table

SELECT *
FROM netflix;


-- To count the number of rows on the table

SELECT 
	COUNT(*)
FROM netflix;


-- To see the unique information (types of movies) in "Type column"
SELECT DISTINCT(type)
FROM netflix;



-- 15 Business Problems & Solutions


-- 1. Count the number of Movies vs TV Shows
SELECT 
	type,
	COUNT(type) AS num_movies_and_TV_shows
FROM netflix
GROUP BY type;


-- 2. Find the most common rating for movies and TV shows
SELECT 
	type,
	rating
FROM
	(SELECT
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix
	GROUP BY type, rating) AS rank
WHERE ranking = 1;


-- 3. List all movies released in a specific year (e.g., 2020)
SELECT 
	type,
	title,
	release_year
FROM netflix
WHERE type = 'Movie'
	AND release_year = 2020


-- 4. Find the top 5 countries with the most content on Netflix
SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
	COUNT(type) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;


-- 5. Identify the longest movie
SELECT 
	title,
	type,
	duration
FROM netflix
WHERE type = 'Movie'
	AND duration = (SELECT 
						MAX(duration)
					FROM netflix);


-- 6. Find content added in the last 5 years
SELECT 
	title,
	type,
	date_added
FROM netflix
WHERE 
	TO_DATE(date_added, 'Month, DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years' /* To convert text to date 
																			and to get date of the last 5 years */


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';


-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::NUMERIC > 5  /*-- To split strings or date, 
												extract info and convert text to number */

-- 9. Count the number of content items in each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY genre;


/* 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release! */
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month, DD, YYYY')) AS year,
	COUNT(*) AS yearly_content,
	ROUND(COUNT(*)::NUMERIC / (SELECT
							COUNT(*)
						  FROM netflix
						  WHERE country = 'India'):: NUMERIC * 100, 2) AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY year;


-- 11. List all movies that are documentaries
SELECT *
FROM netflix
WHERE listed_in ILIKE '%documentaries%'


-- 12. Find all content without a director
SELECT *
FROM netflix
WHERE director IS NULL;


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors,
	COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY actors
ORDER BY total_content DESC
LIMIT 10;


/* 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
WITH new_table
	AS
		(SELECT 
			*,
			CASE
				WHEN description ILIKE '%kill%'
					 OR description ILIKE '%violence%' THEN 'Bad Content'
				ELSE 'Good Content'
			END AS category
		FROM netflix)
SELECT
	category,
	COUNT(*) AS total_content
FROM new_table
GROUP BY category;


