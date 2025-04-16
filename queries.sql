/* 
   Question 1:
   Create a query that lists each movie, the film category it is classified in, 
   and the number of times it has been rented out.
   (Used for visualization on Slide 1) 
*/

SELECT 
    f.title AS film_title, 
    c.name AS category_name, 
    COUNT(*) AS rental_count
FROM 
    category c
JOIN 
    film_category fc ON fc.category_id = c.category_id
JOIN 
    film f ON f.film_id = fc.film_id
JOIN 
    inventory i ON i.film_id = f.film_id
JOIN 
    rental r ON r.inventory_id = i.inventory_id
GROUP BY 
    f.title, c.name
ORDER BY 
    c.name, f.title;



/* 
   Question 2:
   Write a query that returns the store ID, the year and month, 
   and the number of rental orders each store has fulfilled for that month.
   (Used for visualization on Slide 2) 
*/

WITH t1 AS (
    SELECT 
        DATE_PART('month', r.rental_date) AS rental_month,
        DATE_PART('year', r.rental_date) AS rental_year,
        sto.store_id AS store_id
    FROM 
        store sto
    JOIN 
        staff sta ON sto.store_id = sta.store_id
    JOIN 
        rental r ON sta.staff_id = r.staff_id
)
SELECT 
    rental_month,
    rental_year,
    store_id,
    COUNT(*) AS count_rentals
FROM 
    t1
GROUP BY 
    rental_month, rental_year, store_id
ORDER BY 
    count_rentals DESC;



/* 
   Question 3:
   Retrieve the total payment amount for each month by the top 10 paying customers.
   (Used for visualization on Slide 3) 
*/

WITH customer_totals AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS fullname,
        SUM(p.amount) AS total_payment
    FROM 
        customer c
    JOIN 
        payment p ON c.customer_id = p.customer_id
    GROUP BY 
        c.customer_id, c.first_name, c.last_name
    ORDER BY 
        total_payment DESC
    LIMIT 10
),
top_customer_payments AS (
    SELECT 
        DATE_TRUNC('month', p.payment_date) AS pay_mon,
        CONCAT(c.first_name, ' ', c.last_name) AS fullname,
        SUM(p.amount) AS total_monthly_payment,
        COUNT(*) AS payment_count
    FROM 
        customer c
    JOIN 
        payment p ON c.customer_id = p.customer_id
    WHERE 
        c.customer_id IN (SELECT customer_id FROM customer_totals)
        AND DATE_PART('year', p.payment_date) = 2007
    GROUP BY 
        pay_mon, fullname
)
SELECT 
    pay_mon,
    fullname,
    payment_count AS pay_countpermon,
    total_monthly_payment AS pay_amount
FROM 
    top_customer_payments
ORDER BY 
    fullname, pay_mon;



/* 
   Question 4:
   Retrieve the total payment amount collected by each store, including a cumulative total.
   (Used for visualization on Slide 4) 
*/

SELECT 
    s.store_id,
    SUM(p.amount) AS total_payment,
    SUM(SUM(p.amount)) OVER (ORDER BY s.store_id) AS cumulative_payment
FROM 
    store s
JOIN 
    customer c ON s.store_id = c.store_id
JOIN 
    payment p ON c.customer_id = p.customer_id
GROUP BY 
    s.store_id
ORDER BY 
    total_payment DESC;
