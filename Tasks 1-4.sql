/*_______________________ Task 1 _______________________*/

/* Query for first letter*/
WITH RECURSIVE Alph(c) AS (
	SELECT 'A' 
	UNION ALL 
	SELECT CHAR(UNICODE(c) + 1) FROM Alph 
	WHERE UNICODE(c) < UNICODE('Z')
)
SELECT * FROM Alph
WHERE c NOT IN (SELECT DISTINCT SUBSTRING(Code, 1, 1) FROM country)

/* Query for second letter*/
WITH RECURSIVE Alph(c) AS (
	SELECT 'A' 
	UNION ALL 
	SELECT CHAR(UNICODE(c) + 1) FROM Alph 
	WHERE UNICODE(c) < UNICODE('Z')
)
SELECT * FROM Alph
WHERE c NOT IN (SELECT DISTINCT SUBSTRING(Code, 2, 1) FROM country)

/* Query for third letter*/
WITH RECURSIVE Alph(c) AS (
	SELECT 'A' 
	UNION ALL 
	SELECT CHAR(UNICODE(c) + 1) FROM Alph 
	WHERE UNICODE(c) < UNICODE('Z')
)
SELECT * FROM Alph
WHERE c NOT IN (SELECT DISTINCT SUBSTRING(Code, 3, 1) FROM country)


/*_______________________ Task 2 _______________________*/

WITH A AS (
	SELECT Population/CAST(SurfaceArea AS FLOAT) AS Ratio 
	FROM country
)
SELECT 'Maximum' as Metric, MAX(Ratio) as Value FROM A
UNION
SELECT 'Minimum', MIN(Ratio) FROM A
UNION
SELECT 'Median', MEDIAN(Ratio) FROM A;

/*_______________________ Task 3 _______________________*/

SELECT
	country.Name,
	city.Population / CAST(country.Population AS FLOAT) * 100 AS Percentage 
FROM country 
JOIN city 
ON country.Capital = city.ID 
ORDER BY Percentage
LIMIT 10;

/*_______________________ Task 4 _______________________*/

/* Simple Way */
SELECT AVG(c.LifeExpectancy) AS LifeExpectancy,
cl.Language 
FROM country AS c
JOIN countrylanguage AS cl
ON c.Code = cl.CountryCode 
GROUP BY cl.Language

/* Correct way (Should be) */
SELECT SUM(c.LifeExpectancy * cl.Percentage / 100.0 * c.Population) / SUM(cl.Percentage / 100.0 * c.Population) AS LifeExpectancy,
	cl.Language
FROM country AS c
JOIN countrylanguage AS cl
ON c.Code = cl.CountryCode 
GROUP BY cl.Language



