{{ config(materialized='table') }}

WITH Quartiles AS (
    SELECT
        datetime,
        entity,
        average_tone,
        NTILE(4) OVER (ORDER BY average_tone) AS quartile_group
    FROM gdelt_db.stg_qiang
),
Stats AS (
    SELECT
        MAX(CASE WHEN quartile_group = 1 THEN average_tone END) AS Q1,
        MIN(CASE WHEN quartile_group = 4 THEN average_tone END) AS Q3
    FROM Quartiles
),
IQRCALC AS (
    SELECT
        Q1,
        Q3,
        (Q3 - Q1) AS IQR,
        Q1 - (1.5 * (Q3 - Q1)) AS LowerBound,
        Q3 + (1.5 * (Q3 - Q1)) AS UpperBound
    FROM Stats
),
Filtered AS (
    SELECT b.*
    FROM gdelt_db.stg_qiang AS b
    JOIN Quartiles AS q ON b.datetime = q.datetime
    CROSS JOIN IQRCALC
    WHERE q.average_tone BETWEEN IQRCALC.LowerBound AND IQRCALC.UpperBound
      AND b.entity = 'Li Qiang'
),
RollingAvg AS (
    SELECT
        f.*,
        AVG(f.average_tone) OVER (
            ORDER BY f.datetime
            ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
        ) AS rolling_avg_90d
    FROM Filtered AS f
)
SELECT *
FROM RollingAvg
ORDER BY datetime