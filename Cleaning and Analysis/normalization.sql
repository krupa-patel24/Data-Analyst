-- normalization  

/*Since the listed_in column contains multiple genres separated by commas, the data was normalized to analyze genre-level trends accurately.
 After splitting genres into individual records, it was observed that Action and Drama are among the most dominant genres on the platform.*/


-- create table
CREATE TABLE k.genre_table (
    show_id VARCHAR(20),
    genre VARCHAR(200)
);


-- check max genre in one row
SELECT MAX(
    LENGTH(listed_in) - LENGTH(REPLACE(listed_in, ',', '')) + 1
) AS max_genres
FROM k.project_clean;

-- split data in genre_table

INSERT INTO k.genre_table (show_id, genre)
SELECT 
    show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', numbers.n), ',', -1)) AS genre
FROM k.project_clean
JOIN (
    SELECT 1 n UNION ALL
    SELECT 2 UNION ALL
    SELECT 3 UNION ALL
    SELECT 4 UNION ALL
    SELECT 5
) numbers
ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= numbers.n - 1;


