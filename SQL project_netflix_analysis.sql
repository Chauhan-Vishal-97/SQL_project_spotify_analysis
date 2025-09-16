-- SQL ADVANCE PROJECT SPOTIFY DATASETS

-- CREATE TABLE AND IMPORT DATASET
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
	Artist		VARCHAR(70),
	Track		VARCHAR(500),
	Album		VARCHAR(500),
	Album_type	VARCHAR(50),
	Danceability FLOAT,
	Energy		FLOAT,
	Loudness	FLOAT,
	Speechiness	FLOAT,
	Acousticness FLOAT,
	Instrumentalness FLOAT,
	Liveness		FLOAT,
	Valence		FLOAT,
	Tempo		FLOAT,
	Duration_min FLOAT,
	Title		VARCHAR(250),
	Channel		VARCHAR(100),
	Views		FLOAT,
	Likes		BIGINT,
	Comments	BIGINT,
	Licensed	BOOLEAN,
	official_video	BOOLEAN,
	Stream		BIGINT,
	EnergyLiveness	FLOAT,
	most_playedon	VARCHAR(20)
);

-- DATA CLEANING
-- 1. Changed column 'Like, comments, views' into number formate for decimal formate in excel file.
-- 2. Change ' to " in escape parameter while importing dataset because as our table has ' in some of the column


--EDA
SELECT COUNT(*) FROM spotify;
SELECT COUNT(DISTINCT(artist)) FROM spotify;
SELECT COUNT(DISTINCT(album)) FROM spotify;
SELECT DISTINCT(album_type) FROM spotify;
SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify;

SELECT
	*
FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0;

SELECT DISTINCT(COUNT(title)) FROM spotify;
SELECT COUNT(DISTINCT(channel)) FROM spotify;
SELECT DISTINCT(most_playedon) FROM spotify;

-- DATA ANALYSES
-- EASY CATEGORY QURIES

-- 1.Retrieve the names of all tracks that have more than 1 billion streams.
SELECT
	*
FROM spotify
WHERE stream>1000000000;

-- 2.List all albums along with their respective artists.
SELECT
	DISTINCT(album),
	artist
FROM spotify
ORDER BY 1;

-- conclusion of above query:
-- If an album has multiple artists → you’ll see multiple rows (one per artist)
-- If the same (album, artist) pair appears more than once → duplicates are removed

-- 3.Get the total number of comments for tracks where licensed = TRUE.
SELECT
	SUM(comments) AS total_comments
FROM spotify
WHERE licensed = 'true';

-- 4.Find all tracks that belong to the album type single.
SELECT
	track,
	album_type
FROM spotify
WHERE album_type ILIKE '%single%';

-- 5.Count the total number of tracks by each artist.

SELECT
	artist,
	COUNT(track) as no_of_tracks
FROM spotify
GROUP BY 1;

-- MEDIUM CATEGORY QUERIES

-- 6.Calculate the average danceability of tracks in each album.
SELECT
	album,
	AVG(danceability) AS average_danceability
FROM spotify
GROUP BY 1;

-- 7.Find the top 5 tracks with the highest energy values.
SELECT
	track,
	MAX(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 8.List all tracks along with their views and likes where official_video = TRUE.
SELECT
	track,
	official_video,
	SUM(views) as total_views,
	SUM(likes) as total_likes
FROM spotify
GROUP BY 1,2
HAVING official_video = 'true';

-- 9.For each album, calculate the total views of all associated tracks.
SELECT
	album,
	track,
	SUM(views) as total_views
FROM spotify
GROUP BY 1,2;

-- 10.Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT
	*
FROM(SELECT
	track,
	COALESCE(SUM(CASE WHEN most_playedon = 'Youtube' THEN stream END),0) AS stream_on_YT,
	COALESCE(SUM(CASE WHEN most_playedon = 'Spotify' THEN stream END),0) AS stream_on_SPFY
FROM spotify
GROUP BY 1)
WHERE stream_on_YT< stream_on_SPFY
AND
stream_on_YT<>0;

-- ADVANCE CATEGORY QUERIES

-- 11.Find the top 3 most-viewed tracks for each artist using window functions.
SELECT
	artist,
	track,
	total_views
FROM (SELECT
	artist,
	track,
	SUM(views) AS total_views,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS ranking
FROM spotify
GROUP BY 1,2
ORDER BY 1,3 DESC)
WHERE ranking BETWEEN 1 AND 3;

-- 12.Write a query to find tracks where the liveness score is above the average.
SELECT
	track,
	liveness
FROM spotify
WHERE liveness> (SELECT AVG(liveness) FROM spotify);

-- 13.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
SELECT
	album,
	max_energy - min_energy AS difference
FROM (SELECT
	album,
	MAX(energy) AS max_energy,
	MIN(energy) AS min_energy
FROM spotify
GROUP BY 1);


-- 14.Find tracks where the energy-to-liveness ratio is greater than 1.2.
-- 15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.






