-- Fraud Detection
-- 1. Unusually high-value transactions
SELECT
	id,
	client_id,
	amount,
	date
FROM transactions_data
WHERE amount > (SELECT AVG(amount) + 3 * STDDEV(amount) FROM transactions_data);

-- 2. To look at the last time the customers made a transaction
SELECT 
	DISTINCT client_id
FROM transactions_data;
SELECT
	client_id,
	max(date) AS last_txn_date
FROM transactions_data
GROUP BY client_id
ORDER BY last_txn_date DESC;

-- 3. Trying to find out inactive customers
With LastTransactionDate AS (
-- Create a CTE to see their last transaction date
	SELECT
		client_id,
		MAX(date) AS last_txn_date
	FROM transactions_data
	GROUP BY client_id
)
SELECT
	CASE
		WHEN last_txn_date > '2024-06-30 23:59:00.0000000' THEN 'Active'
-- Use the CTE to designate customers into active and inactive customers based on this date
		ELSE 'Inactive'
	END AS ActiveVsInactive,
	COUNT(*) AS total_clients
	FROM LastTransactionDate
	GROUP BY 
		CASE
		WHEN last_txn_date > '2024-06-30 23:59:00.0000000' THEN 'Active'
		ELSE 'Inactive'
	END
	ORDER BY total_clients DESC;

-- 4. Multiple Transactions in Short-time
SELECT
	client_id,
	COUNT(*) AS transaction_count,
	MIN(date) AS first_txn,
	MAX(date) AS last_txn
FROM transactions_data
WHERE date >= DATEADD(DAY, -1, GETDATE()) -- Last 24 hours
GROUP BY client_id
HAVING COUNT(*) > 5;


-- 5. Identifying clients whose maximum spend is 5 times higher than their average spending 
SELECT 
	client_id,
	AVG(amount) AS avg_income,
	MAX(amount) AS max_spent,
	MAX(date) AS last_txn_date
FROM transactions_data
GROUP BY client_id
HAVING MAX(amount) > (AVG(amount) * 5)
ORDER BY max_spent DESC;


-- 6. Identifying clients with multiple failed transactions
SELECT
	client_id,
	COUNT(*) AS failed_attempts,
		MAX(date) AS last_txn_date,
		CASE
		WHEN MAX(date) > '2024-06-30 23:59:00.0000000' THEN 'Active'
		ELSE 'Inactive'
		END AS ActivevsInactive
FROM transactions_data
WHERE errors IS NOT NULL
GROUP BY client_id
HAVING COUNT(*) > 3
ORDER BY failed_attempts DESC;




-- 7. To see how the clients who fall within these fraud indicators spend their money
SELECT
	client_id,
	AVG(amount) AS average_spend,
	MAX(amount) AS max_spend,
	COUNT(*) AS failed_attempts
FROM transactions_data
WHERE errors IS NOT NULL
GROUP BY client_id
HAVING COUNT(*) > 20
ORDER BY failed_attempts DESC;

-- 8. I took each individual client from question 7 and looked into their spending habits
SELECT	
	mc.description,
	SUM(t.amount) AS total_amount
FROM transactions_data t
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE client_id = '464'
GROUP BY mc.description 
ORDER BY total_amount DESC;

SELECT	
	mc.description,
	SUM(t.amount) AS total_amount
FROM transactions_data t
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE client_id = '373'
GROUP BY mc.description 
ORDER BY total_amount DESC;

SELECT	
	mc.description,
	SUM(t.amount) AS total_amount
FROM transactions_data t
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE client_id = '476'
GROUP BY mc.description 
ORDER BY total_amount DESC;


SELECT	
	mc.description,
	SUM(t.amount) AS total_amount
FROM transactions_data t
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE client_id = '490'
GROUP BY mc.description 
ORDER BY total_amount DESC;


SELECT	
	mc.description,
	SUM(t.amount) AS total_amount
FROM transactions_data t
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE client_id = '114'
GROUP BY mc.description 
ORDER BY total_amount DESC;


SELECT	
	mc.description,
	SUM(t.amount) AS total_amount
FROM transactions_data t
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE client_id = '53'
GROUP BY mc.description 
ORDER BY total_amount DESC;

SELECT	
	mc.description,
	SUM(t.amount) AS total_amount
FROM transactions_data t
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE client_id = '425'
GROUP BY mc.description 
ORDER BY total_amount DESC;

SELECT	
	mc.description,
	SUM(t.amount) AS total_amount
FROM transactions_data t
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE client_id = '327'
GROUP BY mc.description 
ORDER BY total_amount DESC;

SELECT	
	mc.description,
	SUM(t.amount) AS total_amount
FROM transactions_data t
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE client_id = '96'
GROUP BY mc.description 
ORDER BY total_amount DESC;

SELECT	
	mc.description,
	SUM(t.amount) AS total_amount
FROM transactions_data t
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE client_id = '17'
GROUP BY mc.description 
ORDER BY total_amount DESC;


SELECT	
	mc.description,
	SUM(t.amount) AS total_amount
FROM transactions_data t
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE client_id = '394'
GROUP BY mc.description 
ORDER BY total_amount DESC;

-- 9. To note clients who make transactions at unusual hours
SELECT 
	client_id,
	COUNT(*) AS late_night_txns
FROM transactions_data
WHERE DATEPART(HOUR, date) BETWEEN 0 AND 5
GROUP BY client_id
HAVING COUNT(*) > 1
ORDER BY late_night_txns DESC;

-- 10. To note if these clients record high value transactions
WITH LateNightTxns AS (
	SELECT
		DISTINCT client_id
	FROM transactions_data 
	WHERE DATEPART(HOUR, date) BETWEEN 0 AND 5
	-- To find clients who made transactions between 12 and 5 am.
), FailedAttempts AS (
-- To see if their number of failed attempts, to link a pattern
	SELECT
		client_id,
		COUNT(*) AS failed_attempts
	FROM transactions_data
	WHERE errors IS NOT NULL
	AND client_id IN (SELECT client_id FROM LateNightTxns)
	GROUP BY client_id
	HAVING COUNT(*) > 3
)
SELECT 
	client_id,
	failed_attempts
FROM FailedAttempts
ORDER BY failed_attempts DESC;


-- 11. To note clients who make transactions at odd hours while also transacting from different locations
WITH LateNightTxns AS ( 
	SELECT
		DISTINCT client_id
	FROM transactions_data 
	WHERE DATEPART(HOUR, date) BETWEEN 0 AND 5 -- to extract the hour from the date for me to find the answer
),
MultiStateTransactions AS (
	SELECT
		client_ID,
		COUNT(DISTINCT merchant_state) AS unique_states
	FROM transactions_data
	WHERE client_id IN (SELECT client_id FROM LateNightTxns)
	GROUP BY client_id
	HAVING COUNT(DISTINCT merchant_state) > 3
)
SELECT *
FROM MultiStateTransactions
ORDER BY unique_states DESC;



-- 12. To note who makes transactions from multiple states
SELECT
	client_id,
	COUNT(DISTINCT merchant_state) AS unique_states
FROM transactions_data
GROUP BY client_id
HAVING COUNT(DISTINCT merchant_state) > 1
ORDER BY unique_states DESC;




Print ('Thank you Splendor')
Print ('#AcknowledgeMe')

 




