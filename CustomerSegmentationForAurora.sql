----Customer Demographics
-- Segmentation by Gender

--1. Counting the number of males and females customers in the data
SELECT
	gender, 
	COUNT(*) AS number
FROM users
GROUP BY gender;

--2. total amount spent by both genders
SELECT
	u.gender,
	SUM(t.amount) AS total_amount
FROM users u
JOIN transactions_data t ON u.id = t.client_id
-- Joining the transactions data and clients data to have my answer
GROUP BY u.gender
ORDER BY total_amount DESC;


--3. total transactions per gender
SELECT 
	u.gender,
	COUNT(t.id) AS total_transactions 
	-- to see how many transactions both sexes make
FROM users u
JOIN transactions_data t ON u.id = t.client_id
GROUP BY u.gender;


 --4. average spend per gender
 SELECT
	u.gender,
	AVG(t.amount) AS avg_amount
FROM users u
JOIN transactions_data t ON u.id = t.client_id
GROUP BY u.gender
ORDER BY avg_amount DESC;


--5. Debt per Gender
SELECT 
	gender,
	SUM(total_debt) AS total_debt
FROM users
GROUP BY gender
ORDER BY total_debt DESC;

-- 6. Spending patterns by gender (What do men spend their money on?)
SELECT 
	mc.description,
	SUM(t.amount) AS total_amount
FROM users u
JOIN transactions_data t ON u.id = t.client_id
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE gender = 'Male'
GROUP BY mc.description
ORDER BY total_amount DESC;




-- 7. Spending patterns by gender - focusing on the females this time
SELECT
	mc.description,
	SUM(t.amount) AS total_amount
FROM users u JOIN
 transactions_data t ON u.id = t.client_id
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE gender = 'Female'
GROUP BY mc.description
ORDER BY total_amount DESC;


-- 8. Segmentation by Age
SELECT 
	birth_year, 
	COUNT(*) AS number_of_customers
FROM users
GROUP BY birth_year
ORDER BY number_of_customers DESC;



---9.  Segmentation by income
-- Group customers into income brackets and check their average spending
WITH IncomeBrackets AS (
	SELECT 
		id,
		yearly_income,
		CASE
			WHEN yearly_income < 20000 THEN 'Low Income'
			WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income'
			WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper-Middle'
			ELSE 'High Income'
		END AS income_category
	FROM users
)
SELECT 
	income_category, 
	COUNT(id) AS total_customers,
	ROUND(AVG(yearly_income),2) AS average_income
FROM IncomeBrackets
GROUP BY income_category
ORDER BY average_income DESC;


-- 10. Spending patterns by age

-- For youth
SELECT
	mc.description,
	SUM(t.amount) AS total_amount
FROM users u
JOIN transactions_data t ON u.id = t.client_id
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE u.current_age<35
GROUP BY mc.description
ORDER BY total_amount DESC;

-- 11. average spend for youths
SELECT
	mc.description,
	AVG(t.amount) AS average_amount
FROM users u
JOIN transactions_data t ON u.id = t.client_id
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE u.current_age<35
GROUP BY mc.description
ORDER BY average_amount DESC;


--12.  for middle-age
-- To find the total spend
SELECT
	mc.description,
	SUM(t.amount) AS total_amount
FROM users u
JOIN transactions_data t ON u.id = t.client_id
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE u.current_age BETWEEN 35 and 63
GROUP BY mc.description
ORDER BY total_amount DESC;

-- 13. To get the average spend
SELECT
	mc.description,
	AVG(t.amount) AS avg_amount
FROM users u
JOIN transactions_data t ON u.id = t.client_id
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE u.current_age BETWEEN 35 AND 63
GROUP BY mc.description
ORDER BY avg_amount DESC;

--14. Applying the same for older people
-- total spend
SELECT
	mc.description,
	SUM(t.amount) AS total_amount
FROM users u
JOIN transactions_data t ON u.id = t.client_id
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE u.current_age > 63
GROUP BY mc.description
ORDER BY total_amount DESC;

--15. Average spend of senior citizens
SELECT
	mc.description, 
	AVG(t.amount) AS average_amount
FROM users u
JOIN transactions_data t ON u.id = t.client_id
JOIN mcc_codes mc ON t.mcc = mc.mcc_id
WHERE u.current_age > 63
GROUP BY mc.description
ORDER BY average_amount DESC;

--16. Segmentation by age and income
-- I will create a CTE to divide the clients into three and find their total income from there
WITH AgeAndIncome AS (
	SELECT 
		CASE
			WHEN u.current_age<35 THEN 'Youth'
			WHEN u.current_age BETWEEN 35 AND 63 THEN 'Middle Aged'
			ELSE 'Senior Citizen'
			END AS age_group,
		ROUND(SUM(t.amount),2) AS total_spent
	FROM users u
	JOIN transactions_data t ON u.id = t.client_id
	GROUP BY 
		CASE
			WHEN u.current_age<35 THEN 'Youth'
			WHEN u.current_age BETWEEN 35 AND 63 THEN 'Middle Aged'
			ELSE 'Senior Citizen'
			END
)
SELECT 
	age_group,
	total_spent
FROM AgeAndIncome
ORDER BY total_spent DESC;


-- 17. Finding the average spend
WITH AgeAndIncome AS (
	SELECT 
		CASE
			WHEN u.current_age<35 THEN 'Youth'
			WHEN u.current_age BETWEEN 35 AND 63 THEN 'Middle Aged'
			ELSE 'Senior Citizen'
			END AS age_group,
		AVG(t.amount) AS average_spent
	FROM users u
	JOIn transactions_data t ON u.id = t.client_id
	GROUP BY 
		CASE
			WHEN u.current_age<35 THEN 'Youth'
			WHEN u.current_age BETWEEN 35 AND 63 THEN 'Middle Aged'
			ELSE 'Senior Citizen'
			END
)
SELECT 
	age_group,
	average_spent
FROM AgeAndIncome
ORDER BY average_spent DESC;


-- 18. Let us see which generation uses which transaction type
WITH AgeGeneration AS (
	SELECT
		CASE
			WHEN u.current_age<35 THEN 'Youth'
			WHEN u.current_age BETWEEN 35 AND 63 THEN 'Middle Aged'
			ELSE 'Senior Citizen'
			END AS age_group, 
			t.use_chip,
			SUM(t.amount) AS total_spend,
		COUNT(*) AS total_transactions
	FROM users u
	JOIN transactions_data t ON u.id = t.client_id 
	GROUP BY t.use_chip,
			CASE
			WHEN u.current_age<35 THEN 'Youth'
			WHEN u.current_age BETWEEN 35 AND 63 THEN 'Middle Aged'
			ELSE 'Senior Citizen'
			END 
)
SELECT 
	age_group,
	use_chip,
	total_transactions,
	total_spend
FROM AgeGeneration
ORDER BY total_transactions DESC;


