-- 1. Top 10 Most Delayed Airlines
SELECT TOP 10 
    OP_CARRIER,
    SUM(total_flights) AS total_flights,
    AVG(avg_dep_delay) AS avg_dep_delay,
    AVG(avg_arr_delay) AS avg_arr_delay
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY OP_CARRIER
ORDER BY avg_dep_delay DESC

-- 2. Yearly Flight Trends
SELECT 
    YEAR(FL_DATE) AS year,
    SUM(total_flights) AS total_flights,
    AVG(avg_dep_delay) AS avg_dep_delay,
    AVG(cancellation_rate) AS avg_cancellation_rate
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY YEAR(FL_DATE)
ORDER BY year

-- 3. Most Reliable Airlines (Lowest Cancellation Rate)
SELECT TOP 10
    OP_CARRIER,
    SUM(total_flights) AS total_flights,
    AVG(cancellation_rate) AS avg_cancellation_rate,
    AVG(avg_dep_delay) AS avg_dep_delay
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY OP_CARRIER
ORDER BY avg_cancellation_rate ASC

-- 4. Busiest Travel Months
SELECT 
    MONTH(FL_DATE) AS month,
    SUM(total_flights) AS total_flights,
    AVG(avg_dep_delay) AS avg_dep_delay
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY MONTH(FL_DATE)
ORDER BY month

-- 5. Worst Performing Months (Highest Delays)
SELECT TOP 5
    YEAR(FL_DATE) AS year,
    MONTH(FL_DATE) AS month,
    SUM(total_flights) AS total_flights,
    AVG(avg_dep_delay) AS avg_dep_delay,
    AVG(avg_arr_delay) AS avg_arr_delay
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY YEAR(FL_DATE), MONTH(FL_DATE)
ORDER BY avg_dep_delay DESC

-- 6. Total Flights Per Airline (All Time)
SELECT 
    OP_CARRIER,
    SUM(total_flights) AS total_flights
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY OP_CARRIER
ORDER BY total_flights DESC

-- 7. Average Departure Delay by Year and Airline
SELECT 
    YEAR(FL_DATE) AS year,
    OP_CARRIER,
    AVG(avg_dep_delay) AS avg_dep_delay
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY YEAR(FL_DATE), OP_CARRIER
ORDER BY year, avg_dep_delay DESC

-- 8. Airlines With Highest Average Distance (Long Haul)
SELECT TOP 10
    OP_CARRIER,
    AVG(avg_distance) AS avg_distance,
    SUM(total_flights) AS total_flights
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY OP_CARRIER
ORDER BY avg_distance DESC

-- 9. Flight Volume Trend by Quarter
SELECT 
    YEAR(FL_DATE) AS year,
    DATEPART(QUARTER, FL_DATE) AS quarter,
    SUM(total_flights) AS total_flights,
    AVG(avg_dep_delay) AS avg_dep_delay
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY YEAR(FL_DATE), DATEPART(QUARTER, FL_DATE)
ORDER BY year, quarter

-- 10. Best Airlines (Lowest Avg Arrival Delay)
SELECT TOP 10
    OP_CARRIER,
    AVG(avg_arr_delay) AS avg_arr_delay,
    SUM(total_flights) AS total_flights
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY OP_CARRIER
ORDER BY avg_arr_delay ASC

-- 11. Cancellation Rate Trend Over Years
SELECT 
    YEAR(FL_DATE) AS year,
    AVG(cancellation_rate) AS avg_cancellation_rate,
    SUM(total_flights) AS total_flights
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY YEAR(FL_DATE)
ORDER BY year

-- 12. Departure vs Arrival Delay Comparison Per Airline
SELECT 
    OP_CARRIER,
    AVG(avg_dep_delay) AS avg_dep_delay,
    AVG(avg_arr_delay) AS avg_arr_delay,
    AVG(avg_dep_delay) - AVG(avg_arr_delay) AS delay_difference
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY OP_CARRIER
ORDER BY delay_difference DESC

-- 13. Top 5 Busiest Days of Week for Flights
SELECT TOP 5
    DATENAME(WEEKDAY, FL_DATE) AS day_of_week,
    SUM(total_flights) AS total_flights,
    AVG(avg_dep_delay) AS avg_dep_delay
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY DATENAME(WEEKDAY, FL_DATE)
ORDER BY total_flights DESC

-- 14. Airlines Operating Short Haul Routes (Lowest Avg Distance)
SELECT TOP 10
    OP_CARRIER,
    AVG(avg_distance) AS avg_distance,
    SUM(total_flights) AS total_flights,
    AVG(avg_dep_delay) AS avg_dep_delay
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY OP_CARRIER
ORDER BY avg_distance ASC

-- 15. Overall Summary Statistics
SELECT 
    COUNT(*) AS total_records,
    SUM(total_flights) AS total_flights_ever,
    AVG(avg_dep_delay) AS overall_avg_dep_delay,
    AVG(avg_arr_delay) AS overall_avg_arr_delay,
    AVG(cancellation_rate) AS overall_cancellation_rate,
    AVG(avg_distance) AS overall_avg_distance
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]

-- 16. Airlines With Most Improved Delay Over Years
SELECT 
    OP_CARRIER,
    YEAR(FL_DATE) AS year,
    AVG(avg_dep_delay) AS avg_dep_delay,
    AVG(avg_arr_delay) AS avg_arr_delay
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY OP_CARRIER, YEAR(FL_DATE)
ORDER BY OP_CARRIER, year

-- 17. Flight Volume by Season
SELECT 
    CASE 
        WHEN MONTH(FL_DATE) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(FL_DATE) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(FL_DATE) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END AS season,
    SUM(total_flights) AS total_flights,
    AVG(avg_dep_delay) AS avg_dep_delay,
    AVG(cancellation_rate) AS avg_cancellation_rate
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY 
    CASE 
        WHEN MONTH(FL_DATE) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(FL_DATE) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(FL_DATE) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END
ORDER BY total_flights DESC

-- 18. Top 10 Airlines by Cancellation Count
SELECT TOP 10
    OP_CARRIER,
    SUM(total_flights) AS total_flights,
    AVG(cancellation_rate) AS avg_cancellation_rate,
    SUM(total_flights) * AVG(cancellation_rate) AS estimated_cancellations
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY OP_CARRIER
ORDER BY estimated_cancellations DESC

-- 19. Monthly Average Delay Heatmap Data
SELECT 
    YEAR(FL_DATE) AS year,
    MONTH(FL_DATE) AS month,
    AVG(avg_dep_delay) AS avg_dep_delay,
    AVG(avg_arr_delay) AS avg_arr_delay,
    SUM(total_flights) AS total_flights
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY YEAR(FL_DATE), MONTH(FL_DATE)
ORDER BY year, month

-- 20. Airline Performance Scorecard
SELECT 
    OP_CARRIER,
    SUM(total_flights) AS total_flights,
    AVG(avg_dep_delay) AS avg_dep_delay,
    AVG(avg_arr_delay) AS avg_arr_delay,
    AVG(cancellation_rate) AS avg_cancellation_rate,
    AVG(avg_distance) AS avg_distance,
    CASE 
        WHEN AVG(avg_dep_delay) < 0 THEN 'Excellent'
        WHEN AVG(avg_dep_delay) BETWEEN 0 AND 5 THEN 'Good'
        WHEN AVG(avg_dep_delay) BETWEEN 5 AND 15 THEN 'Average'
        ELSE 'Poor'
    END AS performance_rating
FROM OPENROWSET(
    BULK 'https://airlinedelaylake.dfs.core.windows.net/gold/flights_aggregated/*.parquet',
    FORMAT = 'PARQUET'
) AS [result]
GROUP BY OP_CARRIER
ORDER BY avg_dep_delay ASC
