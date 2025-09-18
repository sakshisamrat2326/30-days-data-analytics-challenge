





 


-- CREATE DATABASE IPL_HISTORY_ANALYTICS;
-- Staging table



DROP TABLE stg_matches;
CREATE TABLE stg_matches (
    match_id INT,
    inning INT,
    batting_team VARCHAR(100),
    bowling_team VARCHAR(100),
    [over] INT,
    ball INT,
    batter VARCHAR(100),
    bowler VARCHAR(100),
    batsman_runs INT,
    extra_runs INT,
    total_runs INT,
    extras_type VARCHAR(50),
    is_wicket INT,
    player_dismissed VARCHAR(100),
    dismissal_kind VARCHAR(50),
    fielder VARCHAR(100),
    match_year INT
);

BULK INSERT stg_matches
FROM 'C:\Users\Sakshi\Downloads\IPL_History_Cleaned_Final_Stripped.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

CREATE TABLE ipl_player_stats (
    player_name VARCHAR(100),
    match_id INT,
    balls_faced INT,
    runs INT,
    spending_amount FLOAT
);


INSERT INTO ipl_player_stats (player_name, match_id, balls_faced, runs, spending_amount)
SELECT 
    batter AS player_name,
    match_id,
    COUNT(ball) AS balls_faced,
    SUM(batsman_runs) AS runs,
    ROUND(RAND(CHECKSUM(NEWID())) * 1.5 + 1.5, 2) AS spending_amount
FROM stg_matches
GROUP BY batter, match_id;


 

-- Full query: 2 CTEs + 1 CASE, one row per player

WITH Player_Total_Runs AS (
    SELECT 
        player_name,
        SUM(runs) AS total_runs
    FROM ipl_player_stats
    GROUP BY player_name
),
Above_Avg_Players AS (
    SELECT 
        player_name,
        total_runs
    FROM Player_Total_Runs
    WHERE total_runs > (SELECT AVG(total_runs) FROM Player_Total_Runs)
)
SELECT 
    a.player_name,
    a.total_runs,
    ROUND(AVG(p.spending_amount), 2) AS avg_spending_amount,
    CASE 
        WHEN AVG(p.spending_amount) >= 2.0 THEN 'High Spender'
        WHEN AVG(p.spending_amount) >= 1.7 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS spender_category
FROM Above_Avg_Players a
INNER JOIN ipl_player_stats p 
    ON a.player_name = p.player_name
GROUP BY a.player_name, a.total_runs
ORDER BY a.total_runs DESC;

-- Top 10 IPL players leaderboard with spending category

WITH Player_Total_Runs AS (
    SELECT 
        player_name,
        SUM(runs) AS total_runs
    FROM ipl_player_stats
    GROUP BY player_name
),
Above_Avg_Players AS (
    SELECT 
        player_name,
        total_runs
    FROM Player_Total_Runs
    WHERE total_runs > (SELECT AVG(total_runs) FROM Player_Total_Runs)
)
SELECT TOP 10
    a.player_name AS [Player Name],
    a.total_runs AS [Total Runs],
    ROUND(AVG(p.spending_amount), 2) AS [Average Spending],
    CASE 
        WHEN AVG(p.spending_amount) >= 2.0 THEN 'High Spender'
        WHEN AVG(p.spending_amount) >= 1.7 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS [Spender Category]
FROM Above_Avg_Players a
INNER JOIN ipl_player_stats p 
    ON a.player_name = p.player_name
GROUP BY a.player_name, a.total_runs
ORDER BY a.total_runs DESC;



-- Target: 2 CTEs + 1 CASE
-- Top 10 IPL Players Leaderboard (Runs + Spending + Wickets)

WITH Player_Total_Runs AS (
    SELECT 
        player_name,
        SUM(runs) AS total_runs
    FROM ipl_player_stats
    GROUP BY player_name
),
Player_Spending AS (
    SELECT 
        player_name,
        ROUND(AVG(spending_amount), 2) AS avg_spending
    FROM ipl_player_stats
    GROUP BY player_name
),
Player_Wickets AS (
    SELECT 
        bowler AS player_name,
        COUNT(*) AS total_wickets
    FROM stg_matches
    WHERE is_wicket = 1 
          AND dismissal_kind NOT IN ('run out', 'retired hurt', 'obstructing the field') 
    GROUP BY bowler
)
SELECT TOP 10
    r.player_name AS [Player Name],
    r.total_runs AS [Total Runs],
    ISNULL(w.total_wickets, 0) AS [Total Wickets],
    s.avg_spending AS [Average Spending],
    CASE 
        WHEN s.avg_spending >= 2.0 THEN 'High Spender'
        WHEN s.avg_spending >= 1.7 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS [Spender Category]
FROM Player_Total_Runs r
INNER JOIN Player_Spending s 
    ON r.player_name = s.player_name
LEFT JOIN Player_Wickets w 
    ON r.player_name = w.player_name
ORDER BY r.total_runs DESC;


--day13:
USE IPL_HISTORY_ANALYTICS;
GO

--  1. Rank players by total runs within each team
SELECT 
    batter,
    batting_team,
    SUM(batsman_runs) AS total_runs,
    RANK() OVER (PARTITION BY batting_team ORDER BY SUM(batsman_runs) DESC) AS team_rank
FROM stg_matches
GROUP BY batter, batting_team;

--  2. Running total of runs scored by each batter (match-wise order)
SELECT 
    match_id,
    batter,
    SUM(batsman_runs) OVER (
        PARTITION BY batter 
        ORDER BY match_id 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM stg_matches;

--  3. Average runs per match & compare with overall average using window
SELECT
    batter,
    match_id,
    SUM(batsman_runs) AS runs_in_match,
    AVG(SUM(batsman_runs)) OVER (PARTITION BY batter) AS avg_runs_per_match
FROM stg_matches
GROUP BY batter, match_id;

--  4. Top 3 batters overall using DENSE_RANK
SELECT *
FROM (
    SELECT 
        batter,
        SUM(batsman_runs) AS total_runs,
        DENSE_RANK() OVER (ORDER BY SUM(batsman_runs) DESC) AS overall_rank
    FROM stg_matches
    GROUP BY batter
) t
WHERE overall_rank <= 3;

--Day 14 � Window Functions II

--1. Compare each batter�s match runs with previous match (LAG)
WITH MatchRuns AS (
    SELECT 
        match_id,
        batter,
        SUM(batsman_runs) AS runs
    FROM stg_matches
    GROUP BY match_id, batter
)
SELECT 
    batter,
    match_id,
    runs,
    LAG(runs, 1, 0) OVER (PARTITION BY batter ORDER BY match_id) AS prev_match_runs,
    runs - LAG(runs, 1, 0) OVER (PARTITION BY batter ORDER BY match_id) AS run_diff
FROM MatchRuns
ORDER BY batter, match_id;

--2. Compare each batter�s match runs with next match (LEAD)
WITH MatchRuns AS (
    SELECT 
        match_id,
        batter,
        SUM(batsman_runs) AS runs
    FROM stg_matches
    GROUP BY match_id, batter
)
SELECT 
    batter,
    match_id,
    runs,
    LEAD(runs, 1, 0) OVER (PARTITION BY batter ORDER BY match_id) AS next_match_runs,
    LEAD(runs, 1, 0) OVER (PARTITION BY batter ORDER BY match_id) - runs AS diff_next
FROM MatchRuns
ORDER BY batter, match_id;

--3. First & Last match performance of each batter (FIRST_VALUE / LAST_VALUE)
WITH MatchRuns AS (
    SELECT 
        match_id,
        batter,
        SUM(batsman_runs) AS runs
    FROM stg_matches
    GROUP BY match_id, batter
)
SELECT 
    batter,
    match_id,
    runs,
    FIRST_VALUE(runs) OVER (PARTITION BY batter ORDER BY match_id) AS first_match_runs,
    LAST_VALUE(runs) OVER (PARTITION BY batter ORDER BY match_id 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_match_runs
FROM MatchRuns
ORDER BY batter, match_id;


--  Day15:
USE IPL_HISTORY_ANALYTICS;


-- 1️ Match-wise total runs (basic GROUP BY)
SELECT 
    match_id,
    batting_team,
    SUM(total_runs) AS total_runs
FROM stg_matches
GROUP BY match_id, batting_team
ORDER BY match_id, batting_team;

-- 2️ Using ROLLUP → Get totals per match + grand total
SELECT 
    match_id,
    batting_team,
    SUM(total_runs) AS total_runs
FROM stg_matches
GROUP BY ROLLUP (match_id, batting_team);

-- 3️  Using CUBE → Get all combinations (match, team, both, grand total)
SELECT 
    match_id,
    batting_team,
    SUM(total_runs) AS total_runs
FROM stg_matches
GROUP BY CUBE (match_id, batting_team);

-- 4️ GROUPING SETS → Flexible control
--  Example: totals by match, totals by team, and overall
SELECT 
    match_id,
    batting_team,
    SUM(total_runs) AS total_runs
FROM stg_matches
GROUP BY GROUPING SETS (
    (match_id), 
    (batting_team), 
    ()
);

-- 5️ Label NULLs for clarity (using GROUPING function)
SELECT 
    ISNULL(CAST(match_id AS VARCHAR), 'All Matches') AS match_id,
    ISNULL(batting_team, 'All Teams') AS batting_team,
    SUM(total_runs) AS total_runs,
    GROUPING(match_id) AS grp_match,
    GROUPING(batting_team) AS grp_team
FROM stg_matches
GROUP BY ROLLUP (match_id, batting_team);


/* Day 16: Mastering Subqueries with IPL Data */


USE IPL_HISTORY_ANALYTICS;
GO

-- 1️ Subquery in SELECT Clause → Compare runs vs. average runs
SELECT 
    batter,
    SUM(batsman_runs) AS total_runs,
    AVG(SUM(batsman_runs)) OVER () AS avg_runs -- window function
FROM stg_matches
GROUP BY batter;
-- 2️ Subquery in FROM Clause → Derived table for top scorers
SELECT 
    t.batter,
    t.total_runs
FROM (
    SELECT 
        batter,
        SUM(batsman_runs) AS total_runs
    FROM stg_matches
    GROUP BY batter
) t
WHERE t.total_runs > 5000
ORDER BY t.total_runs DESC;

-- 3️  Subquery in WHERE Clause → Players above overall average
SELECT 
    batter,
    SUM(batsman_runs) AS total_runs
FROM stg_matches
GROUP BY batter
HAVING SUM(batsman_runs) > (
    SELECT AVG(total_runs) 
    FROM (
        SELECT SUM(batsman_runs) AS total_runs
        FROM stg_matches
        GROUP BY batter
    ) avg_table
);

-- 4️ Correlated Subquery → Players who scored above their own match average
SELECT DISTINCT
    s1.batter,
    s1.match_id,
    SUM(s1.batsman_runs) AS runs_in_match
FROM stg_matches s1
GROUP BY s1.batter, s1.match_id
HAVING SUM(s1.batsman_runs) > (
    SELECT AVG(s2.batsman_runs)
    FROM stg_matches s2
    WHERE s1.batter = s2.batter
);

-- 5️ Subquery with IN → Matches where Virat Kohli played
SELECT DISTINCT match_id
FROM stg_matches
WHERE batter = 'V Kohli';

SELECT *
FROM stg_matches
WHERE match_id IN (
    SELECT DISTINCT match_id
    FROM stg_matches
    WHERE batter = 'V Kohli'
);

--Day 17: Data Cleaning in SQL

-- 1.Handle Missing Player Names (NULLIF, COALESCE)

-- Replace empty strings with NULL, then coalesce to 'Unknown'
SELECT 
    COALESCE(NULLIF(batter, ''), 'Unknown') AS clean_batter,
    SUM(batsman_runs) AS total_runs
FROM stg_matches
GROUP BY COALESCE(NULLIF(batter, ''), 'Unknown');


--2. Standardize Team Names (CASE, REPLACE)
-- Fix inconsistent team names
SELECT 
    CASE 
        WHEN batting_team LIKE '%Delhi%' THEN 'Delhi Capitals'
        WHEN batting_team LIKE '%Punjab%' THEN 'Punjab Kings'
        ELSE batting_team
    END AS standardized_team,
    SUM(total_runs) AS total_runs
FROM stg_matches
GROUP BY 
    CASE 
        WHEN batting_team LIKE '%Delhi%' THEN 'Delhi Capitals'
        WHEN batting_team LIKE '%Punjab%' THEN 'Punjab Kings'
        ELSE batting_team
    END;


--3.Remove extra spaces
	-- Clean spacing issues in bowler names
SELECT 
    TRIM(bowler) AS clean_bowler,
    COUNT(*) AS deliveries
FROM stg_matches
GROUP BY TRIM(bowler);

--4.Handle Null / Invalid Dismissal Types
-- Replace NULLs or invalid dismissal kinds with 'Not Applicable'
SELECT 
    COALESCE(NULLIF(dismissal_kind, ''), 'Not Applicable') AS clean_dismissal,
    COUNT(*) AS count_events
FROM stg_matches
GROUP BY COALESCE(NULLIF(dismissal_kind, ''), 'Not Applicable');


--5.Regex-like Cleanup (SQL Server LIKE / PATINDEX)
-- Find invalid player names (numeric or special chars)
SELECT *
FROM stg_matches
WHERE batter LIKE '%[0-9]%' OR batter LIKE '%[^a-zA-Z ]%';


/* Day 18:Exploratory Data Analysis (EDA) with SQL   */


SELECT *from ipl_player_stats
SELECT *FROM stg_matches

--1. Player performance summary

SELECT TOP 10
       batter,
       COUNT(*) AS innings_played,
       SUM(batsman_runs) AS total_runs,
       ROUND(AVG(batsman_runs), 2) AS avg_runs
FROM stg_matches
GROUP BY batter
ORDER BY total_runs DESC;

--2.Most consistent batsmen (min 200 balls faced)

SELECT TOP 10 
       batter,
       COUNT(*) AS balls_faced, --Total number of balls faced (assuming each row = one ball).
       SUM(batsman_runs) AS total_runs, -- Total runs scored by the batsman.
       ROUND(SUM(batsman_runs) * 100.0 / COUNT(*), 2) AS strike_rate
FROM stg_matches
GROUP BY batter
HAVING COUNT(*) > 200
ORDER BY strike_rate DESC

--3.total runs per team in each match

SELECT match_id , batting_team,
   SUM (batsman_runs) AS team_total
   from stg_matches
Group By match_id , batting_team
Order by match_id ,  team_total DESC;

--4.Top run-scorers

SELECT TOP 10
    match_id,
    batter,
    SUM(batsman_runs) AS total_runs
FROM stg_matches
GROUP BY match_id, batter
ORDER BY total_runs DESC;


