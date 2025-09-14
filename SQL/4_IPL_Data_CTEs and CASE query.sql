
CREATE DATABASE IPL_HISTORY_ANALYTICS;
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


--CTE – Player Total Runs
-- Full query: 2 CTEs + 1 CASE (Fixed)

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

