CREATE DATABASE spotify_analytics;
USE spotify_analytics;
SELECT COUNT(*) AS total_rows
FROM spotify_tracks;
USE spotify_analytics;

DESCRIBE spotify_tracks;
USE spotify_analytics;
SHOW TABLES;
SELECT * FROM spotify_tracks LIMIT 5;
SELECT YEAR(STR_TO_DATE(release_date, '%d-%m-%Y')) AS release_year, COUNT(*) AS total_tracks 
FROM spotify_tracks GROUP BY YEAR(STR_TO_DATE(release_date, '%d-%m-%Y')) ORDER BY release_year;
select monthname(str_to_date(release_date, '%d-%m-%Y')) as release_month, count(*) as total_tracks
from spotify_tracks 
group by month(STR_TO_DATE(release_date, '%d-%m-%Y')),
    monthname(STR_TO_DATE(release_date, '%d-%m-%Y'))
ORDER BY total_tracks DESC;
SELECT
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'spotify_analytics'
  AND TABLE_NAME = 'spotify_tracks'
ORDER BY ORDINAL_POSITION;
select release_year, sum(stream_count) AS total_streams, lag (sum(stream_count)) over ( order by release_year) as previous_year_streams
FROM spotify_tracks
GROUP BY release_year
ORDER BY release_year;
WITH yearly_streams AS (
    SELECT
        release_year,
        SUM(stream_count) AS total_streams
    FROM spotify_tracks
    GROUP BY release_year
)

SELECT
    release_year,
    total_streams,
    LAG(total_streams) OVER (
        ORDER BY release_year
    ) AS previous_year_streams,
    total_streams - LAG(total_streams) OVER (
        ORDER BY release_year
    ) AS stream_difference
FROM yearly_streams
ORDER BY release_year;
WITH yearly_streams AS (
    SELECT
        release_year,
        SUM(stream_count) AS total_streams
    FROM spotify_tracks
    GROUP BY release_year
)

SELECT
    release_year,
    total_streams,
    LAG(total_streams) OVER (
        ORDER BY release_year
    ) AS previous_year_streams,
    total_streams - LAG(total_streams) OVER (
        ORDER BY release_year
    ) AS stream_difference,
    ROUND(
        (
            total_streams - LAG(total_streams) OVER (
                ORDER BY release_year
            )
        ) / LAG(total_streams) OVER (
            ORDER BY release_year
        ) * 100,
        2
    ) AS yoy_growth_percent
FROM yearly_streams
ORDER BY release_year;
WITH yearly_streams AS (
    SELECT
        release_year,
        SUM(stream_count) AS total_streams
    FROM spotify_tracks
    GROUP BY release_year
)

SELECT
    release_year,
    total_streams,
    LEAD(total_streams) OVER (
        ORDER BY release_year
    ) AS next_year_streams
FROM yearly_streams
ORDER BY release_year;
WITH artist_genre_streams AS (
    SELECT
        genre,
        artist_name,
        SUM(stream_count) AS total_streams
    FROM spotify_tracks
    GROUP BY
        genre,
        artist_name
)

SELECT
    genre,
    artist_name,
    total_streams,
    ROW_NUMBER() OVER (
        PARTITION BY genre
        ORDER BY total_streams DESC
    ) AS genre_rank
FROM artist_genre_streams
ORDER BY
    genre,
    genre_rank;
    CREATE VIEW vw_genre_performance AS
SELECT
    genre,
    COUNT(*) AS total_tracks,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(popularity), 2) AS avg_popularity,
    ROUND(AVG(danceability), 2) AS avg_danceability,
    ROUND(AVG(energy), 2) AS avg_energy
FROM spotify_tracks
GROUP BY genre;
SELECT
    genre,
    total_tracks,
    total_streams,
    avg_popularity,
    avg_danceability,
    avg_energy
FROM vw_genre_performance
ORDER BY total_streams DESC;
CREATE VIEW vw_genre_analysis AS
SELECT
    genre,
    COUNT(*) AS total_tracks,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS avg_streams,
    ROUND(AVG(popularity), 2) AS avg_popularity,
    ROUND(AVG(danceability), 2) AS avg_danceability,
    ROUND(AVG(energy), 2) AS avg_energy,
    ROUND(AVG(duration_minutes), 2) AS avg_duration_minutes
FROM spotify_tracks
GROUP BY genre;
SELECT
    genre,
    total_tracks,
    total_streams,
    avg_streams,
    avg_popularity,
    avg_danceability,
    avg_energy,
    avg_duration_minutes
FROM vw_genre_analysis
ORDER BY total_streams DESC;
CREATE OR REPLACE VIEW vw_genre_analysis AS
SELECT
    genre,
    COUNT(*) AS total_tracks,
    COUNT(DISTINCT artist_name) AS total_artists,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS avg_streams,
    ROUND(AVG(popularity), 2) AS avg_popularity,
    ROUND(AVG(danceability), 2) AS avg_danceability,
    ROUND(AVG(energy), 2) AS avg_energy,
    ROUND(AVG(duration_minutes), 2) AS avg_duration_minutes
FROM spotify_tracks
GROUP BY genre;
SELECT
    genre,
    total_tracks,
    total_artists,
    total_streams,
    avg_streams,
    avg_popularity,
    avg_danceability,
    avg_energy,
    avg_duration_minutes
FROM vw_genre_analysis
ORDER BY total_streams DESC;