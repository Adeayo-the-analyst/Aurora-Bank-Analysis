-- Transactions and High-Level Summaries
-- High-level summary

-- 1. To find the total transactions 

SELECT 
	COUNT(*) AS total_transactions 
FROM transactions_data;

-- 2. To find the total transaction amount

SELECT
	SUM(amount) AS total_transaction_value 
	FROM transactions_data;

-- 3. Total transactions per chip
SELECT
	use_chip,
	COUNT(*) AS total_transactions 
	FROM transactions_data
GROUP BY use_chip
ORDER BY total_transactions;

-- 4. Total amount per chip
SELECT
	use_chip,
	SUM(amount) AS total_transaction_value 
FROM transactions_data
GROUP BY use_chip
ORDER BY total_transaction_value DESC;

-- 5. Average amount per chip
SELECT	
	use_chip,
	AVG(amount) AS average_amount 
FROM transactions_data
GROUP BY use_chip
ORDER BY average_amount DESC;

-- 6. Total transactions per merchant category (Top 20)
SELECT TOP 20
	m.description,
	COUNT(*) AS total_transactions
	FROM transactions_data t
JOIN mcc_codes m ON t.mcc = m.mcc_id
GROUP BY m.description
ORDER BY total_transactions ASC;

-- 7. Total amount per merchant category
SELECT
	m.description,
	SUM(t.amount) AS total_amount 
FROM transactions_data t
JOIN mcc_codes m ON t.mcc = m.mcc_id
GROUP BY m.description
ORDER BY total_amount DESC;

-- 8. Average amount per merchant category
SELECT
	m.description,
	AVG(t.amount) AS average_amount
FROM transactions_data t
JOIN mcc_codes m ON t.mcc = m.mcc_id
GROUP BY m.description
ORDER BY average_amount DESC;

-- 9. Total amount per merchant state
SELECT 	merchant_state,
	SUM(amount) AS total_amount
FROM transactions_data
WHERE merchant_state IS NOT NULL
-- to remove null values
GROUP BY merchant_state
ORDER BY total_amount DESC;

-- 10. Average amount per merchant state
SELECT
	merchant_state,
	AVG(amount) AS average_amount
FROM transactions_data
WHERE merchant_state IS NOT NULL
GROUP BY merchant_state
ORDER BY average_amount DESC;

-- Failed transactions

-- 1. Find the number of all failed transactions
SELECT
	errors,
	COUNT(*) AS total_errors
FROM transactions_data
WHERE errors IS NOT NULL
GROUP BY errors
ORDER BY total_errors DESC;

-- 2. Total value lost to failed transactions
SELECT
	errors,
	SUM(amount) AS total_amount 
FROM transactions_data
WHERE errors IS NOT NULL
GROUP BY errors
ORDER BY total_amount DESC;

-- 3. States having the highest amounts of failed transactions
SELECT
	merchant_state, 
	errors,
	SUM(amount) AS total_amount
FROM transactions_data
WHERE errors IS NOT NULL
GROUP BY merchant_state, errors
ORDER BY total_amount DESC;


-- 4. Testing out something 
SELECT
	merchant_state,
	SUM(amount) AS total_amount
FROM transactions_data
WHERE merchant_state IS NULL
AND merchant_city = 'ONLINE' 
-- I realized that null values in merchant state were linked to 'online' in merchant city
AND errors IS NOT NULL
GROUP BY merchant_state;

-- 5. Counting the failed online transactions
SELECT
	merchant_state,
	COUNT(*) AS total_transactions
FROM transactions_data
WHERE merchant_state IS NULL
AND errors IS NOT NULL
GROUP BY merchant_state;

-- 6. Looking at the types of errors and the amount lost to them
SELECT
	errors,
	SUM(amount) AS total_amount
FROM transactions_data
WHERE merchant_state IS NULL
AND errors IS NOT NULL
GROUP BY merchant_state, errors
ORDER BY total_amount DESC;


-- 7. Successful vs Failed Transactions rate
SELECT
	COUNT(*) AS total_transactions,
	SUM(CASE WHEN errors IS NULL THEN 1 ELSE 0 END) AS successful_transactions,
	SUM(CASE WHEN errors IS NOT NULL THEN 1 ELSE 0 END) AS failed_transactions,
	(SUM(CASE WHEN errors IS NOT NULL THEN 1 ELSE 0 END) * 100.0)/ COUNT(*) AS failure_rate_percentage
FROM transactions_data;

-- 8. Total failed transactions by use chips
SELECT
	use_chip,
	COUNT(*) AS total_errors
FROM transactions_data
WHERE errors IS NOT NULL
GROUP BY use_chip
ORDER BY total_errors DESC;

-- 9. Total money lost to failed transactions based on chip
SELECT
	use_chip,
	SUM(amount) AS total_amount_lost
FROM transactions_data
WHERE errors IS NOT NULL
GROUP BY use_chip
ORDER BY total_amount_lost DESC;

-- 10. Error count of the different types of errors under chip transaction
SELECT 
errors,
COUNT (*) AS error_count
FROM transactions_data
WHERE use_chip = 'Chip Transaction'
AND errors IS NOT NULL
GROUP BY errors
ORDER BY error_count DESC;

-- 11. Failure rate by merchant_id
SELECT
	merchant_id,
	COUNT(*) AS total_transactions,
	SUM(CASE WHEN errors IS NULL THEN 1 ELSE 0 END) AS successful_transactions,
	SUM(CASE WHEN errors IS NOT NULL THEN 1 ELSE 0 END) AS failed_transactions,
	(SUM(CASE WHEN errors IS NOT NULL THEN 1 ELSE 0 END) * 100.0)/ COUNT(*) AS failure_rate_percentage
FROM transactions_data
GROUP BY merchant_id
HAVING SUM(CASE WHEN errors IS NOT NULL THEN 1 ELSE 0 END) > 100
ORDER BY failure_rate_percentage DESC;


-- 12 failure rate by merchant_state
SELECT
	merchant_state,
	COUNT(*) AS total_transactions,
	SUM(CASE WHEN errors IS NULL THEN 1 ELSE 0 END) AS successful_transactions,
	SUM(CASE WHEN errors IS NOT NULL THEN 1 ELSE 0 END) AS failed_transactions,
	(SUM(CASE WHEN errors IS NOT NULL THEN 1 ELSE 0 END) * 100.0)/ COUNT(*) AS failure_rate_percentage
FROM transactions_data
GROUP BY merchant_state
HAVING SUM(CASE WHEN errors IS NOT NULL THEN 1 ELSE 0 END) > 100
ORDER BY failure_rate_percentage DESC;




