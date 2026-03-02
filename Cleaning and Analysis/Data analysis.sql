-- BASIC EXPLORATORY Analysis

-- 1.Movies and TV Shows ratio

select type ,count(*),
round(count(*) * 100.0 / (select count(*)from k.project_clean),2) as percentage
from k.project_clean
group by type;

-- 2.unique countries 

select distinct country from k.project_clean
order by country;

-- 3.unique directors

select distinct director from k.project_clean
order by director;

-- 4.oldest release year

select min(release_year) from k.project_clean
limit 1;

-- 5.letest release year

select max(release_year) from k.project_clean
limit 1;

-- 6.How many titles were added each year

select count(*) as total_titles,year(date_added) as year from k.project_clean
group by year
order by  total_titles desc;

-- 7.Was there an increase in content during 2020–2021

select year(date_added) as year_added,
	count(*) as total_titles 
from k.project_clean
where year(date_added) in (2019,2021,2020)
group by year(date_added)
order by total_titles ;


-- 8.What is the yearly trend of Movies vs TV Shows

select type,
release_year as year_added,
count(*) as total
 from k.project_clean
 group by release_year,type
 order by total desc;
 
-- 9.What is the growth rate in the last 5 years 


select year(date_added) as year,
count(*),
count(*) - lag(count(*)) over(order by year(date_added)) as grouth
from k.project_clean
group by year(date_added)
order by year desc
limit 5;

-- 10.Is the platform focusing more on recent releases

SELECT 
    CASE 
        WHEN release_year >= 2018 THEN 'recent'
        ELSE 'Older Content'
    END AS category,
    COUNT(*) AS total_titles
FROM k.project_clean
GROUP BY category;


-- 11.Which are the top 10 content-producing countries

select country ,count(*) total
from k.project_clean
group by country
order by total desc
limit 10;

-- 12.Which countries produce more Movies than TV Shows

SELECT country,
       SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS total_movies,
       SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS total_tvshows
FROM k.project_clean
GROUP BY country
HAVING total_movies > total_tvshows
ORDER BY total_movies DESC;

-- 13.Comparison between India and USA

select country,count(*) as total
from k.project_clean
where country in ('United states', 'India')
group by country;

-- 14.Is any country showing rapid growth over the years

SELECT country,
       release_year,
       COUNT(*) AS total_titles,
       COUNT(*) - LAG(COUNT(*)) OVER (PARTITION BY country ORDER BY release_year) AS yearly_growth
FROM k.project_clean
GROUP BY country, release_year
ORDER BY country, release_year;

-- 15.Which country has the highest average movie duration

select country,round(avg(duration_numeric),2) as avg
from k.project_clean
where duration_unit='minutes'
and type= 'movie'
group by country
order by avg desc;

-- 20. What are the top 10 most common genres

select genre,count(*) as total
from k.genre_table
group by genre
order by total desc
limit 10;

-- 21.Most popular genre in Movies

SELECT 
    g.genre,
    COUNT(*) AS total_movies
FROM k.project_clean p
LEFT JOIN k.genre_table g
    ON p.show_id = g.show_id
WHERE p.type = 'Movie'
GROUP BY g.genre
ORDER BY total_movies DESC
LIMIT 1;

-- 21.Most popular genre in Tv shows

SELECT 
    g.genre,
    COUNT(*) AS total_movies
FROM k.project_clean p
LEFT JOIN k.genre_table g
    ON p.show_id = g.show_id
WHERE p.type = 'Tv show'
GROUP BY g.genre
ORDER BY total_movies DESC
LIMIT 1;

-- 22.Is the Action & Adventure genre increasing over time

SELECT 
    p.release_year,
    COUNT(*) AS total_action_titles
FROM k.project_clean p
INNER JOIN k.genre_table g
    ON p.show_id = g.show_id
WHERE g.genre = 'Action & Adventure'
GROUP BY p.release_year
ORDER BY p.release_year desc;

-- 23.How many genres are assigned per title on average

select avg(total) as avg_gen
from(
select show_id,count(genre) as total
from k.genre_table
group by show_id
) as genre_count;


-- RATING ANALYSIS

-- 1.What is the most common content rating

select rating_category,count(*) as total from k.project_clean
group by rating_category
order by total desc;

-- 2.How does rating distribution differ between Movies and TV Shows

select type,rating_category,count(*) as total
from k.project_clean
group by type,rating_category
order  by type,total desc;

-- 3.Is mature/adult content increasing over the years

select release_year,count(rating_category) as rating from k.project_clean
where rating_category ='Adult'
group by release_year
order by release_year desc;


-- 4.What is the most common rating per country

SELECT country, rating_category, total
FROM (
    SELECT 
        country,
        rating_category,
        COUNT(*) AS total,
        ROW_NUMBER() OVER (
            PARTITION BY country 
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM k.project_clean
    WHERE country IS NOT NULL
    GROUP BY country, rating_category
) ranked
WHERE rn = 1
ORDER BY country;

-- DURATION ANALYSIS

-- 1.What is the average movie duration

SELECT AVG(duration_numeric) as avg_duration
from k.project_clean
where duration_unit='minutes';

-- 2.What is the most common movie duration range

SELECT 
    CASE 
        WHEN duration_numeric < 90 THEN 'Under 90 min'
        WHEN duration_numeric BETWEEN 90 AND 120 THEN '90-120 min'
        WHEN duration_numeric BETWEEN 121 AND 150 THEN '121-150 min'
        ELSE '150+ min'
    END AS duration_range,
    COUNT(*) AS total_movies
FROM k.project_clean
WHERE type = 'Movie'
GROUP BY duration_range
ORDER BY total_movies DESC;

-- 3.What is the most common number of seasons in TV Shows

SELECT 
    duration_numeric AS seasons,
    COUNT(*) AS total_shows
FROM k.project_clean
WHERE type = 'TV Show'
GROUP BY duration_numeric
ORDER BY total_shows DESC;

-- 4.Are multi-season shows increasing
 
SELECT 
    release_year,
    COUNT(CASE WHEN duration_numeric > 1 THEN 1 END) * 100.0 
    / COUNT(*) AS multi_season_percentage
FROM k.project_clean
WHERE type = 'TV Show'
GROUP BY release_year
ORDER BY release_year;