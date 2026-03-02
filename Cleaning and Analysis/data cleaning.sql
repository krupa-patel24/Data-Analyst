-- import csv file

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/p.csv'
INTO TABLE k.project_clean
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(show_id, type, title, director, country, @date_added, release_year, rating, duration, listed_in)
SET date_added = STR_TO_DATE(@date_added, '%d-%m-%Y');

-- understand dataset

select * from k.project_clean
limit 20;
-- check columns data types

desc k.project_clean;

-- check duplicate and remove it
 
WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY show_id, type, title, director, country,
                            date_added, release_year, rating, duration, listed_in
               ORDER BY show_id
           ) AS rn
    FROM k.project_clean
)
delete  from k.project_clean
WHERE show_id IN (
    SELECT show_id FROM cte WHERE rn > 1
);

DELETE  FROM K.project_clean
WHERE SHOW_ID IN(
    SELECT SHOW_ID FROM(
        SELECT SHOW_ID,
                ROW_NUMBER() OVER(PARTITION BY director,TITLE,COUNTRY,RELEASE_YEAR ORDER BY SHOW_ID  ) AS RN
FROM K.project_clean
)T
WHERE RN>1
);


-- check null values

select count(*) from k.project_clean
where director is null;

select count(*) from k.project_clean
where country is null; 

-- remove extra space

UPDATE k.project_clean
SET rating = TRIM(rating)
WHERE rating <> TRIM(rating);

UPDATE k.project_clean
SET title = TRIM(title)
WHERE title <> TRIM(title);

UPDATE k.project_clean
SET director = TRIM(director)
WHERE director <> TRIM(director);

UPDATE k.project_clean
SET country = TRIM(country)
WHERE country <> TRIM(country);

-- Text Standardization


UPDATE k.project_clean
SET title = CONCAT(
    UPPER(LEFT(title,1)),
    LOWER(SUBSTRING(title,2))
);

UPDATE k.project_clean
SET COUNTRY = CONCAT(
    UPPER(LEFT(COUNTRY,1)),
    LOWER(SUBSTRING(COUNTRY,2))
);

UPDATE k.project_clean
SET DIRECTOR = CONCAT(
    UPPER(LEFT(DIRECTOR,1)),
    LOWER(SUBSTRING(DIRECTOR,2))
);

/*
Feature Engineering – Duration Standardization

Transformed the raw duration column into 
analytics-ready structured fields by extracting 
numeric values and separating units (Minutes/Seasons).

This enhances query performance and enables 
quantitative analysis such as average movie length 
and season distribution.
*/

alter table k.project_clean
add column duration_numeric INT;

UPDATE k.project_clean
SET duration_numeric = 
CASE 
    WHEN duration LIKE '%min%' 
        THEN CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED)
    WHEN duration LIKE '%Season%' 
        THEN CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED)
END;

alter table k.project_clean
add column duration_unit varchar(20);

UPDATE k.project_clean
SET duration_unit =
CASE
    WHEN duration LIKE '%min%' THEN 'Minutes'
    WHEN duration LIKE '%Season%' THEN 'Seasons'
END;


-- Identify Outliers

select * from k.project_clean
where release_year > year(curdate());

select * from k.project_clean
where date_added > curdate();


/*
Added a derived column 'rating_category' and 
bucketed raw ratings into age-based segments 
using CASE statement for better business analysis.
*/

ALTER TABLE k.project_clean
ADD COLUMN rating_category VARCHAR(20);

UPDATE k.project_clean
SET rating_category =
CASE  
    WHEN rating IN ('G','TV-G','TV-Y','TV-Y7') THEN 'Kids'  
    WHEN rating IN ('PG','TV-PG') THEN 'Family'  
    WHEN rating IN ('PG-13','TV-14') THEN 'Teen'  
    WHEN rating IN ('R','NC-17','TV-MA') THEN 'Adult'  
    ELSE 'Uncategorized'  
END;

-- Remove Unwanted Columns
alter table k.project_clean
drop column duration;

-- final clean data check
select * from k.project_clean;

select count(*) from k.project_clean;