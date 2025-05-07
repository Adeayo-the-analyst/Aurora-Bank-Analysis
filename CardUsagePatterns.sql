-- Card Usage Patterns
-- 1. To check the card used the most by customers.
SELECT
	card_type,
	COUNT(*) AS number_of_cards
FROM cards
GROUP BY card_type
ORDER BY number_of_cards DESC;

SELECT  -- to check the average number of cards per customer
avg(num_credit_cards) AS average_number_of_credit_cards
FROM users;


-- 2. I want to know the average number of credit cards based on demographics
SELECT 
	CASE
		WHEN current_age<35 THEN 'Youth'
		WHEN current_age BETWEEN 35 AND 63 THEN 'Middle Aged'
		ELSE 'Senior Citizen'
		END AS age_group,
	count(*) AS number_of_customers
	FROM users
GROUP BY 
	CASE
		WHEN current_age<35 THEN 'Youth'
		WHEN current_age BETWEEN 35 AND 63 THEN 'Middle Aged'
		ELSE 'Senior Citizen'
		END
ORDER BY number_of_customers DESC;

-- 3. The card brand customers use the most
SELECT
	card_brand,
	COUNT(*) AS total_cards
FROM cards
GROUP BY card_brand
ORDER BY card_brand DESC;

-- 4. How many customers have multiple cards?
SELECT
	num_cards_issued,
	COUNT(*) AS total_count
FROM cards
GROUP BY num_cards_issued
ORDER BY total_count DESC;

-- 5. How many cards expired in 2024?
SELECT
	COUNT(*) AS total_cards
FROM cards
WHERE expires LIKE '%24';

-- 6. How many cards have chips?
SELECT 
	has_chip,
	COUNT(*) AS total_cards
FROM cards
GROUP BY has_chip
ORDER BY total_cards DESC;

-- 7. Account tenure and chip type
SELECT 
	acct_open_date,
	AVG(credit_limit) AS credit_limit,
	AVG(num_cards_issued) AS avg_num_cards
FROM cards
GROUP BY acct_open_date
ORDER BY avg_num_cards DESC;

--8. Let us know which customers use a debit card, credit card, prepaid or all
SELECT
	COUNT(DISTINCT c1.client_id) AS total_customers,
	COUNT(DISTINCT CASE WHEN c1.card_type = 'Credit' THEN c1.client_ID END) AS customers_with_credit,
	COUNT(DISTINCT CASE WHEN c1.card_type = 'Debit' THEN c1.client_ID END) AS customers_with_debit,
	COUNT(DISTINCT CASE WHEN c1.card_type = 'Debit (Prepaid)' THEN c1.client_ID END) AS customers_with_prepaid,
	COUNT(DISTINCT CASE WHEN c1.card_type = 'Credit' AND c2.client_id IS NOT NULL THEN c1.client_id END) AS customers_with_both
FROM cards c1
LEFT JOIN cards c2
ON c1.client_id = c2.client_id



-- 9. To know which age segment uses the card type
SELECT 
	CASE
		WHEN u.current_age<35 THEN 'Youth'
		WHEN u.current_age BETWEEN 35 AND 63 THEN 'Middle Aged'
		ELSE 'Senior Citizen'
		END AS age_group,
	c.card_type,
	COUNT(*) AS total_customers
FROM users u
JOIN cards c on u.id = c.client_id
GROUP BY c.card_type, 
			CASE
				WHEN u.current_age<35 THEN 'Youth'
				WHEN u.current_age BETWEEN 35 AND 63 THEN 'Middle Aged'
				ELSE 'Senior Citizen'
				END
ORDER BY total_customers DESC;

-- 10. Looking at customers with old pins
SELECT 
	COUNT(*) AS customers_with_old_pins
FROM cards
WHERE year_pin_last_changed <= YEAR(GETDATE()) - 10;

