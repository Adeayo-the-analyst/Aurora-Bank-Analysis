-- Debt Analysis

-- Debt-Credit Ratio

-- 1. We are looking at the customers with the highest risk of defaulting on their loans
SELECT TOP 10 
	id,
	yearly_income,
	total_debt,
	ROUND((total_debt * 1.0 /nullif(yearly_income, 0)),2) AS debt_to_income_ratio
FROM users 
ORDER BY debt_to_income_ratio DESC;

 -- 2. to see the average debt per gender
SELECT
	gender,
	AVG(total_debt) AS avg_debt
FROM users
GROUP BY gender;

--3. I want to write a query to see which customers are debt-free
SELECT
	COUNT(*) AS total_users,
	SUM(CASE WHEN total_debt = 0 THEN 1 ELSE 0 END) AS debt_free_clients,
	SUM(CASE WHEN total_debt > 0 THEN 1 ELSE 0 END) AS indebted_clients,
	(SUM(CASE WHEN total_debt > 0 THEN 1 ELSE 0 END) * 100.0)/ COUNT(*) AS debtor_percentage
FROM users;

--4. To know the age segments most indebted
SELECT
	CASE
		WHEN u.current_age<35 THEN 'Youth'
		WHEN u.current_age BETWEEN 35 AND 63 THEN 'Middle Aged'
		ELSE 'Senior Citizen'
		END AS age_group,
	SUM(total_debt) AS total_debt
FROM users u
GROUP BY CASE
		WHEN u.current_age<35 THEN 'Youth'
		WHEN u.current_age BETWEEN 35 AND 63 THEN 'Middle Aged'
		ELSE 'Senior Citizen'
		END
ORDER BY total_debt DESC;


 -- 5. the customers with credit scores below 600 who have the highest debt_to_income ratio
SELECT TOP 10
	id,
	credit_score,
	yearly_income,
	total_debt,
	ROUND((total_debt * 1.0 /nullif(yearly_income, 0)),2) AS debt_to_income_ratio
FROM users 
WHERE credit_score < 600
ORDER BY debt_to_income_ratio DESC;
