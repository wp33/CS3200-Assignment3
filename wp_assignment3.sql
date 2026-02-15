-- Query 1
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS MusicVideo;

CREATE TABLE MusicVideo (
    TrackId INTEGER PRIMARY KEY,
    VideoDirector TEXT NOT NULL,
    FOREIGN KEY (TrackId) REFERENCES tracks(TrackId)
        ON DELETE CASCADE
);

-- Query 2
INSERT OR IGNORE INTO MusicVideo (TrackId, VideoDirector)
SELECT TrackId, 'Director ' || TrackId
FROM tracks
WHERE Name <> 'Voodoo'
ORDER BY TrackId
LIMIT 10;

-- Query 3
INSERT OR IGNORE INTO MusicVideo (TrackId, VideoDirector)
SELECT TrackId, 'Special Director for Voodoo'
FROM tracks
WHERE Name = 'Voodoo';

-- Query 4
SELECT TrackId, Name
FROM tracks
WHERE Name LIKE '%''%'
ORDER BY Name;

-- Query 5
SELECT
  t.Name AS TrackName,
  mv.VideoDirector,
  ar.Name AS Artist,
  al.Title AS Album,
  g.Name AS Genre,
  ROUND(t.Milliseconds / 60000.0, 2) AS Minutes
FROM MusicVideo mv
JOIN tracks t       ON t.TrackId = mv.TrackId
JOIN albums al      ON al.AlbumId = t.AlbumId
JOIN artists ar     ON ar.ArtistId = al.ArtistId
LEFT JOIN genres g  ON g.GenreId = t.GenreId
ORDER BY ar.Name, al.Title, t.Name;

-- Query 6
SELECT
  c.CustomerId,
  c.FirstName || ' ' || c.LastName AS CustomerName,
  c.Country,
  ROUND(SUM(ii.UnitPrice * ii.Quantity), 2) AS TotalSpent
FROM customers c
JOIN invoices i       ON i.CustomerId = c.CustomerId
JOIN invoice_items ii ON ii.InvoiceId = i.InvoiceId
GROUP BY c.CustomerId, c.FirstName, c.LastName, c.Country
ORDER BY TotalSpent DESC
LIMIT 10;

-- Query 7
WITH avg_len AS (
  SELECT AVG(Milliseconds) AS avg_ms
  FROM tracks
  WHERE Milliseconds <= 15 * 60 * 1000
)
SELECT DISTINCT
  c.CustomerId,
  c.FirstName || ' ' || c.LastName AS CustomerName
FROM customers c
JOIN invoices i       ON i.CustomerId = c.CustomerId
JOIN invoice_items ii ON ii.InvoiceId = i.InvoiceId
JOIN tracks t         ON t.TrackId = ii.TrackId
CROSS JOIN avg_len
WHERE t.Milliseconds > avg_len.avg_ms
  AND t.Milliseconds <= 15 * 60 * 1000
ORDER BY CustomerName;

-- Query 8
WITH top_genres AS (
  SELECT GenreId
  FROM tracks
  WHERE GenreId IS NOT NULL
  GROUP BY GenreId
  ORDER BY SUM(Milliseconds) DESC
  LIMIT 5
)
SELECT
  t.TrackId,
  t.Name AS TrackName,
  g.Name AS Genre,
  ROUND(t.Milliseconds / 60000.0, 2) AS Minutes
FROM tracks t
LEFT JOIN genres g ON g.GenreId = t.GenreId
WHERE t.GenreId NOT IN (SELECT GenreId FROM top_genres)
   OR t.GenreId IS NULL
ORDER BY Genre, t.Name;

SELECT COUNT(*) AS VideoCount FROM MusicVideo;
