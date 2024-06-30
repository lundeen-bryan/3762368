/*markdown
This point forward will be in SQLite only because it's more compatible with spatialite and the setup with QGIS.
*/

-- Check deathincrease for Xmas day
SELECT
  deathincrease
, daily.state
, GEOMETRY
FROM
  daily
, state
WHERE
  state.stusps = daily.state
  AND dt = '2020-12-25'

DROP TABLE IF EXISTS spatialtable;
CREATE TABLE spatialtable AS 
  SELECT
    deathincrease
, daily.state
, GEOMETRY
FROM daily, state
WHERE state.stusps = daily.state
AND dt = '2020-12-25';
SELECT recovergeometrycolumn('spatialtable', 'geometry', 4269, 'MULTIPOLYGON');

-- 02. Find avg hospitalizations, cases, and deaths by state
SELECT
  d1.dt
, AVG(CAST(d2.hospitalizedcurrently AS FLOAT)) AS avghosp
, AVG(CAST(d2.deathincrease AS FLOAT)) AS avgdeath
, AVG(CAST(d2.positiveincrease AS FLOAT)) AS avgcases
, d1.deathincrease
FROM
  daily d1
, daily d2
WHERE
  ABS(julianday (d1.dt) - julianday (d2.dt)) < 4
  AND d1.state = 'FL'
  AND d2.state = 'FL'
GROUP BY
  d1.dt
, d1.deathincrease
ORDER BY
  d1.dt DESC

-- 03. Show Avg Death Increase vs Death Increase by Day
SELECT
  d1.dt AS "Date"
, AVG(CAST(d2.positiveincrease AS FLOAT)) AS "Daily Avg Cases"
, d1.deathincrease "Death Increase"
FROM
  daily d1
, daily d2
WHERE
  ABS(julianday (d1.dt) - julianday (d2.dt)) < 4
  AND d1.state = 'FL'
  AND d2.state = 'FL'
GROUP BY
  d1.dt
, d1.deathincrease
ORDER BY
  d1.dt DESC





-- 04. Average Death Increases vs. Death Increases (Chart data)
SELECT
  d1.dt "Date"
, AVG(CAST(d2.deathincrease AS FLOAT)) AS "Avg Death Increase"
, d1.deathincrease "Death Increase"
FROM
  daily d1
, daily d2
WHERE
  ABS(julianday (d1.dt) - julianday (d2.dt)) < 4
  AND d1.state = 'FL'
  AND d2.state = 'FL'
GROUP BY
  d1.dt
, d1.deathincrease
ORDER BY
  d1.dt DESC



/*markdown
Here we see the daily fluctuations of deaths, and the average deaths per day in one chart for Florida. We can change the query above to get a different state such as California. 
 
![](res/2024-06-29-09-27-01.png)


*/

-- 05. Average Death Increases vs. Death Increases (Chart data)
SELECT
  d1.dt "Date"
, AVG(CAST(d2.deathincrease AS FLOAT)) AS "Avg Death Increase"
, d1.deathincrease "Death Increase"
FROM
  daily d1
, daily d2
WHERE
  ABS(julianday (d1.dt) - julianday (d2.dt)) < 4
  AND d1.state = 'CA'
  AND d2.state = 'CA'
GROUP BY
  d1.dt
, d1.deathincrease
ORDER BY
  d1.dt DESC




/*markdown
California had a higher number but also a different shape.
![](res/2024-06-29-09-34-18.png)
*/

-- 06. Find avg hospitalizations, cases, and deaths by state for CA & FL
SELECT
  d1.dt "Date"
, d1.state "ST"
, AVG(CAST(d2.hospitalizedcurrently AS FLOAT)) AS "Avg Hospitalized"
, AVG(CAST(d2.deathincrease AS FLOAT)) AS "Avg Deaths"
, AVG(CAST(d2.positiveincrease AS FLOAT)) AS "Avg Cases"
, d1.deathincrease "Daily Deaths"
FROM
  daily d1
, daily d2
WHERE
  ABS(julianday (d1.dt) - julianday (d2.dt)) < 4
  AND d1.state = d2.state 
  AND d1.state IN ('FL', 'CA')
GROUP BY
  d1.dt
, d1.deathincrease
ORDER BY
  "Avg Deaths" DESC

/*markdown
Note we have to go very far down the table to find where Florida starts showing high death rates. 
*/

-- 07. Find the highest Death Rates for opposing states and the date
SELECT
  "Date"
, "ST"
, "Avg Deaths"
FROM
(
SELECT
  d1.dt "Date"
, d1.state "ST"
, AVG(CAST(d2.hospitalizedcurrently AS FLOAT)) AS "Avg Hospitalized"
, AVG(CAST(d2.deathincrease AS FLOAT)) AS "Avg Deaths"
, AVG(CAST(d2.positiveincrease AS FLOAT)) AS "Avg Cases"
, d1.deathincrease "Daily Deaths"
FROM
  daily d1
, daily d2
WHERE
  ABS(julianday (d1.dt) - julianday (d2.dt)) < 4
  AND d1.state = d2.state 
  AND d1.state IN ('FL', 'CA')
GROUP BY
  d1.dt
, d1.deathincrease
ORDER BY
  "Avg Deaths" DESC
)
GROUP BY "ST"

/*markdown
Surprisingly, this wasn't a typo, both of the highest death tolls occurred on the same day 25-Jan-2021
*/

-- 08. Compare Positive Rates in Two Different States
WITH monthly_stats AS (
    SELECT strftime('%m', dt) AS mnth
         , state
         , sum(positiveincrease) AS totpositive
         , sum(totalTestResultsIncrease - positiveincrease) AS totnegative
      FROM daily
     WHERE 1=1
       AND state IN ('CA', 'FL')  -- Include all states you want to compare
     GROUP BY strftime('%m', dt), state
),
state_stats AS (
    SELECT mnth
         , state
         , totpositive
         , totnegative
         , totpositive + totnegative AS tottests
         , CAST(totpositive AS REAL) / NULLIF(CAST(totpositive + totnegative AS REAL), 0) AS posrate
      FROM monthly_stats
)
SELECT t2.mnth "Month"
     , t2.state AS "State 1"
     , t2.posrate AS "Positive Rate 1"
     , t3.state AS "State 2"
     , t3.posrate AS "Positive Rate 2"
  FROM state_stats t2
 INNER JOIN state_stats t3 ON t2.mnth = t3.mnth
                          AND t2.state = 'CA'  -- Replace with first state of interest
                          AND t3.state = 'FL'; -- Replace with second state of interest




-- 09. Get Positive Rate for a Single State
WITH monthly_stats AS (
    SELECT strftime('%m', dt) AS mnth
         , sum(positiveincrease) AS totpositive
         , sum(totalTestResultsIncrease - positiveincrease) AS totnegative
      FROM daily
     WHERE 1=1
       AND state = 'CA'  -- Replace with your desired state abbreviation
     GROUP BY strftime('%m', dt)
),
state_stats AS (
    SELECT mnth "Month"
         , totpositive "Total Positive"
         , totnegative "Total Negative"
         , totpositive + totnegative AS "Total Tests"
         , CAST(totpositive AS REAL) / NULLIF(CAST(totpositive + totnegative AS REAL), 0) AS "Positive Rate"
      FROM monthly_stats
)
SELECT *
  FROM state_stats;



/*markdown
At this point I need to fix the tables so that I can match keys. 

### Narrative for Matching Tables and Integrating Data

1. **Understanding Table Relationships:**
   - **State and State Population Tables:**
     - Identify and verify that `state.name` in the `state` table matches `statepop.name` in the `statepop` table correctly. This ensures that each state's population data (`statepop`) corresponds accurately to the state details (`state`).

2. **Part 1: Get the Correct State Name:**
   - **Objective:** Match the state abbreviation (`stusps`) from the `state` table with the state name from the `statepop` table.
   - **SQL Code:**
     ```sql
     SELECT stusps, statepop.*
     FROM state, statepop
     WHERE state.name = statepop.name;
     ```
   - **Action Steps:**
     - Review the output to ensure that each `stusps` (state abbreviation) in the `state` table correctly corresponds to the respective state's population data (`statepop`).

3. **Part 2: Join States and COVID Data:**
   - **Objective:** Integrate COVID-19 data (`daily` table) with state population data (`statepop`) using state abbreviations (`stusps`) as the key.
   - **SQL Code:**
     ```sql
     SELECT *
     FROM
         (SELECT geometry, stusps, statepop.*
          FROM state, statepop
          WHERE state.name = statepop.name
         ) AS stpop,
         (SELECT state, sum(positiveIncrease) AS totpositive
          FROM daily
          GROUP BY state
         ) AS stcovid
     WHERE stcovid.state = stpop.stusps;
     ```
   - **Action Steps:**
     - Confirm that the `stusps` from `state` correctly links with `statepop.name`.
     - Verify that `stcovid.state` in the subquery accurately aggregates COVID-19 data (`positiveIncrease`) per state.

4. **Part 3: Calculate Percent Positive:**
   - **Objective:** Compute the percentage of positive COVID-19 cases relative to the state population estimate.
   - **SQL Code:**
     ```sql
     SELECT geometry, stusps,
         CAST(totpositive AS real) / CAST(popestimate2019 AS real) AS percentpositive,
         totpositive
     FROM
         (SELECT geometry, stusps, statepop.*
          FROM state, statepop
          WHERE state.name = statepop.name
         ) AS stpop,
         (SELECT state, sum(positiveIncrease) AS totpositive
          FROM daily
          GROUP BY state
         ) AS stcovid
     WHERE stcovid.state = stpop.stusps;
     ```
   - **Action Steps:**
     - Ensure that `popestimate2019` in `statepop` accurately reflects the estimated population for each state.
     - Validate the calculation of `percentpositive` to correctly represent the percentage of positive cases relative to the state's population.

### Key Considerations:
- **Data Consistency:** Verify that state names (`state.name` and `statepop.name`) are consistent across both tables.
- **Join Conditions:** Double-check join conditions (`stcovid.state = stpop.stusps`) to ensure accurate data linkage.
- **Calculation Accuracy:** Validate calculations (`percentpositive`) to accurately reflect the intended metrics.



*/

-- Part 1, Query that gets the correct state names
SELECT stusps, statepop.*
FROM state, statepop
WHERE state.name = statepop.name



/*markdown
In the next query we just look at how we would join state, statepop, and daily tables
*/

-- Part 2, query that joins the states and covid data
SELECT * FROM
	(SELECT geometry, stusps, statepop.*
	 FROM state, statepop
	 WHERE state.name = statepop.name
	) AS stpop,
		(SELECT state, sum(positiveIncrease) AS totpositive
		FROM daily
		GROUP BY state) AS stcovid
WHERE stcovid.state = stpop.stusps



/*markdown
Part 3 calculates the percentage of positive COVID-19 cases relative to the estimated state population for each state, using data joined from `state`, `statepop`, and `daily` tables based on matching state names or abbreviations.
*/

-- Part 3, Show percent positive
SELECT geometry, stusps,
	CAST(totpositive AS real) / CAST( popestimate2019 AS real) AS percentpositive,
	totpositive
FROM
	(SELECT geometry, stusps, statepop.*
	 FROM state, statepop
	 WHERE state.name = statepop.name
	) AS stpop,
		(SELECT state, sum(positiveIncrease) AS totpositive
		FROM daily
		GROUP BY state) AS stcovid
WHERE stcovid.state = stpop.stusps



/*markdown
## Narrative for the last part

This script drops any existing `spatialtable`, then creates a new table named `spatialtable`. It populates this table with geographic data (`geometry`) and calculates the percentage of positive COVID-19 cases relative to the estimated state population (`percentpositive`). The data is sourced from joined information in `state` and `statepop` tables for state details and population estimates, and `daily` table for COVID-19 statistics aggregated by state. Finally, it ensures that the `geometry` column is properly configured for spatial data using the `recovergeometrycolumn` function.

We run this in Spatialite_gui not here, but I have it here for documentation. 

```sql
DROP TABLE IF EXISTS spatialtable;

CREATE TABLE spatialtable AS
SELECT geometry, stusps,
	CAST(totpositive AS real) / CAST( popestimate2019 AS real) AS percentpositive,
	totpositive
FROM
	(SELECT geometry, stusps, statepop.*
	 FROM state, statepop
	 WHERE state.name = statepop.name
	) AS stpop,
		(SELECT state, sum(positiveIncrease) AS totpositive
		FROM daily
		GROUP BY state) AS stcovid
WHERE stcovid.state = stpop.stusps;

SELECT recovergeometrycolumn('spatialtable', 'geometry', 4269, 'MULTIPOLYGON')
```
*/

/*markdown
Small side-track on data per state using the spatialtable we just made just to illustrate that QGIS can create a map per state if we select the right tables. 

![](res/2024-06-29-11-46-37.png)
*/

-- Part 4 alter daily table so population is a real number
ALTER TABLE daily
ADD COLUMN population real;

-- Part 5 Confirm that the table was altered
-- Enter this command in spatialite_gui to see all data types
PRAGMA table_info(daily);

-- Part 6 confirm table is empty because we didn't add values yet
 SELECT population FROM daily
 limit 5
 ;

-- Part 6.a select all data from stusps and statepop

SELECT stusps, statepop.*
	FROM state, statepop
	WHERE state.name = statepop.name  

-- Part 7 add population data to daily table
UPDATE daily
SET population = popestimate2019
FROM (SELECT stusps, statepop.*
	FROM state, statepop
	WHERE state.name = statepop.name
	) AS t
WHERE daily.state = t.stusps;



-- Part 8 Confirm that the data has been added
 SELECT state, population FROM daily
 limit 5
 ;

/*markdown
These changes were encouraged by the professor at Salisbury in order to make queries easier going forward, however, it's not normal form to put all the data into one table. Not my normal practice. 
*/

-- 10. See Percent of Positive Cases by State
SELECT
  state "State"
, positiveincrease "Daily Positive Cases"
, ROUND((SUM(positiveincrease) / MIN(population)) * 100, 2) || '%' AS "Positive Rate"
FROM
  daily
GROUP BY
  state
ORDER BY
  "Positive Rate" DESC
LIMIT 10

/*markdown
Note: CountyPop table is HUGE so limit results when looking at it. In the next section we'll confirm the changes. 
*/

-- 11. Assign a Region to a County
ALTER TABLE covidcounty ADD COLUMN region TEXT;

UPDATE covidcounty
SET region = countypop.region
FROM countypop
WHERE covidcounty.state = countypop.stname;



-- 11.a Confirm the "region" column was added and no data
SELECT * FROM covidcounty
LIMIT 10

-- 12. Analyze the cencus by region for states
-- run in spatialite_gui because it uses geo data
WITH stpop AS (
  SELECT
    st.state AS stusps,
    sp.*  -- assuming statepop has other columns you need
  FROM
    state AS st
  JOIN
    statepop AS sp ON st.name = sp.name
),
stcovid AS (
  SELECT
    state,
    SUM(deathincrease) AS totdeath
  FROM
    daily
  GROUP BY
    state
)
SELECT
  COUNT(*) AS ct,
  stpop.region,
  SUM(stcovid.totdeath) AS totdeath,
  AVG(stcovid.totdeath) AS avgdeath,
  STDDEV_SAMP(stcovid.totdeath) AS stdev_death,
  STDDEV_SAMP(stcovid.totdeath) / AVG(stcovid.totdeath) AS cv
FROM
  stpop
JOIN
  stcovid ON stcovid.state = stpop.stusps
GROUP BY
  stpop.region;



/*markdown
Mask mandate status as of 2021 from the NY Times 
![](res/2024-06-29-14-21-58.png)
*/

-- 13. Nearby states with different mask mandates in 2021 (per 1M pop)
SELECT
  strftime ('%W', dt) AS wk
, strftime ('%Y', dt) AS yr
, MIN(dt) AS dt
, CAST(hospitalizedcurrently AS FLOAT) / population * 1000000 AS "Pct Hospitalized"
FROM
  daily
WHERE
  state = 'TN' -- change state for another view
GROUP BY
  yr
, wk
ORDER BY
  yr
, wk ASC
limit 10

/*markdown
![](res/2024-06-29-13-26-03.png)
*/

-- 14a. Show Two States Hospitalized Rate Percent per 1M pop
SELECT t.dt,"California Hospitalized", "Florida Hospitalized"
FROM
(SELECT  strftime('%W', dt) AS wk, strftime('%Y', dt) AS yr,
	  min(dt) AS dt,
	  CAST(hospitalizedcurrently AS float)/population*1000000 as "California Hospitalized"
FROM daily
WHERE state = 'CA'
GROUP BY yr,wk
ORDER BY yr,wk ASC) AS t,
(SELECT  strftime('%W', dt) AS wk, strftime('%Y', dt) AS yr,
	  min(dt) AS dt,
	  CAST(hospitalizedcurrently AS float)/population*1000000 as "Florida Hospitalized"
FROM daily
WHERE state = 'FL'
GROUP BY yr,wk
ORDER BY yr,wk ASC) AS t2
WHERE t.dt = t2.dt
LIMIT 5 -- remove to see all data, limited to keep size of notebook small

-- 14b. Show Two States Hospitalized Rate Percent per 1M pop 
-- Significantly easier to read as a CTE
WITH
     Hosp1 AS  (
          SELECT strftime('%W', dt) AS week
               , strftime('%Y', dt) AS year
               , min(dt) AS dt
               , CAST(hospitalizedcurrently AS float)/ population * 1000000 AS first_hosp
            FROM daily
           WHERE state = 'CA' -- State abr of first hospital
        GROUP BY year
               , week)

   , Hosp2 AS  (
          SELECT strftime('%W', dt) AS week
               , strftime('%Y', dt) AS year
               , min(dt) AS dt
               , CAST(hospitalizedcurrently AS float)/ population * 1000000 AS second_hosp
            FROM daily
           WHERE state = 'FL' -- State abr of second hospital
        GROUP BY year
               , week)
/* Outcome */
     SELECT Hosp1.dt "Date"
          , Hosp1.first_hosp AS "California Hospitalized"
          , Hosp2.second_hosp AS "Florida Hospitalized"
       FROM Hosp1
       JOIN Hosp2
         ON Hosp1.dt = Hosp2.dt
   ORDER BY Hosp1.dt
;



/*markdown
![](res/2024-06-29-14-01-39.png)
*/

/*markdown
To make this a little easier I just downloaded the SQLite ODBC driver so I can query direclty in Excel multiple different states and find a pattern. This is easier than updating the PostreSQL database that I made earlier. 

[SQLITE ODBC Driver](http://www.ch-werner.de/sqliteodbc/)

Then a little struggle getting the connection string right. 
It must be 
`Driver={SQLite3 ODBC Driver};Database=[PATH TO SQLITE FILE];`

Now all you have to do is make changes to the query in the advanced M code section like this in the screenshot below: 

![](res/2024-06-29-15-46-13.png)

Ok now let's start making some graphs!

<img src="res/2024-06-29-15-52-40.png" width="700" height="400">

<img src="res/2024-06-29-15-55-01.png" width="700" height="400">

<img src="res/2024-06-29-15-57-25.png" width="700" height="400">



*/

-- 15. Create a spatial table and use geo-data to find new deaths for a
--     day and link to a map - enter this in spatialite_gui
DROP TABLE IF EXISTS
  spatialtable
;


CREATE TABLE
  spatialtable AS
SELECT
  state.pk_uid
, GEOMETRY
, dt
, deathincrease
, stusps
FROM
  daily
, state
WHERE
  dt = '2020-08-10'
  AND daily.state = stusps;
	AND state IN ('CA', 'OR', 'NV', 'AR', 'UT')
SELECT
  recovergeometrycolumn ('spatialtable', 'geometry', 4269, 'MULTIPOLYGON')
;