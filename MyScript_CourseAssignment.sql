use mavenmovies;

-- Jimmy boss wants to email all of our customers. Get the list for him
SELECT first_name, last_name, email FROM customer; 

-- Jimmy wants to confirm that we have only titles that are rented for 3, 5 or 7 days
Select distinct rental_duration FROM film;
-- We do not. We have 4 and 6 as well so we should modify that if our boss only wants 3, 5 or 7 days

-- Jimmy is looking for payment records for first 100 customers of our store
SELECT * FROM payment WHERE customer_id < 101;
SELECT * FROM payment WHERE customer_id BETWEEN 1 AND 100; 
-- Jimmy now wants to see payments over $5 for those customers since Jan 1 2006
SELECT 
    *
FROM
    payment
WHERE
    customer_id < 101 AND amount >= 5
        AND payment_date >= '2006-01-01'; 
-- We want to pull all payments from the customers in the previous query along with payments over $5 from any customer
SELECT 
    *
FROM
    payment
WHERE
    amount >= 5
        OR customer_id IN (42 , 53, 60, 75);
    
-- Jimmy wants to pull a list of films that include a behind the scenes special feature

SELECT title, special_features 
FROM film
WHERE special_features LIKE '%Behind the Scenes%';

-- Jimmy wants to know how long we are renting out our movies and which rental duration is most common
SELECT rental_duration,
COUNT(film_id) AS number_of_films
FROM film
GROUP BY rental_duration;

-- Practice Query
SELECT 
	rating,
    COUNT(film_id),
    MIN(length),
    MAX(length),
    AVG(length)
    FROM film
    GROUP BY 
		rating;
        
/* Jimmy wants to know if we charge more for a rental when the replacement cost is higher
he wants to pull a count of films along with the average min and max rental rates grouped by replacement cost
*/
SELECT 
    replacement_cost,
    COUNT(film_id) AS number_of_films,
    AVG(rental_rate) AS avg_rental,
    MIN(rental_rate) AS cheapest_rental,
    MAX(rental_rate) AS most_expensive
FROM
    film
GROUP BY replacement_cost;

-- Case statements for putting movies in buckets
SELECT DISTINCT length, 
CASE 
	WHEN length < 60 THEN 'Under an hour'
    WHEN length BETWEEN 60 AND 90 THEN "1 - 1.5 hours"
    WHEN length > 90 THEN 'Too long'
    ELSE 'check logic'
END
FROM film;

-- Jimmy would like to know which store customers go to and whether or not they are active. Store 1 and 2

SELECT first_name, last_name,
	CASE 
		WHEN store_id = 1 AND active = 1 THEN 'store 1 active'
    WHEN store_id = 2 AND active = 1 THEN 'store 2 active'
    WHEN store_id = 1 AND active = 0 THEN 'store 1 inactive'
    WHEN store_id = 2 AND active = 0 THEN 'store 2 inactive'
    ELSE 'check'
END AS profile
FROM customer;

SELECT film_id,
COUNT(CASE WHEN store_id = 1 THEN inventory_id ELSE NULL END) AS store_1_copies,
COUNT(CASE WHEN store_id = 2 THEN inventory_id ELSE NULL END) AS store_2_copies,
COUNT(inventory_id) AS total_copies
FROM inventory
GROUP BY film_id
ORDER BY film_id;

-- Jimmy is curious how many inactive customers we have at each store. We can find this by counting the customers and their active statuses at each store

SELECT store_id,
COUNT(CASE WHEN active = 1 THEN customer_id ELSE NULL END) AS active,
COUNT(CASE WHEN active = 0 THEN customer_id ELSE NULL END) AS inactive
FROM customer
GROUP BY store_id;

-- This query acts like a pivot table in excel using active status as our pivot, COUNT(customer_id) as our values, and active and inactive as our columns.alter

-- Bridging tables with 2 joins
use mavenmovies;
SELECT 
	film.film_id,
    film.title,
    category.name AS category_name
FROM film
	INNER JOIN film_category 
    ON film.film_id = film_category.film_id
	INNER JOIN category
    ON film_category.category_id = category.category_id;
    
-- Jimmy wants to pull a list of all actors with each title they appear in.
-- We can do this by bridging tables with multiple joins

SELECT 
	actor.first_name,
	actor.last_name,
    film_actor.film_id,
    film.title AS film
FROM actor
INNER JOIN film_actor
ON actor.actor_id = film_actor.actor_id
INNER JOIN film
ON film_actor.film_id = film.film_id
ORDER BY actor.first_name;

-- Jimmy wants us to pull a list of distinct titles and their descriptions that are available at store 2 
-- Can utilize multi-conditional join to optimize speed of query and obtain correct result here
SELECT 
	DISTINCT film.title,
    film.description

FROM film
INNER JOIN inventory 
ON film.film_id = inventory.film_id
AND inventory.store_id = 2;

-- Unions
SELECT
	'advisor' as type,
    first_name,
    last_name
    FROM advisor
    
UNION

SELECT
	'investor' AS type,
    first_name,
    last_name
    FROM investor;
    
-- Jimmy wants a list of all staff and advisor names. he wants to include a column noting whether they are staff members or advisors
-- Used CONCAT to make things simpler
SELECT 
	'staff member' AS type,
    CONCAT(first_name," ", last_name) AS name 
    FROM staff
UNION

SELECT 
	'advisor' AS type,
    concat(first_name," ",last_name) AS name
    FROM advisor;
    
SELECT customer_id, COUNT(rental_id) AS total_rentals
FROM rental
GROUP BY customer_id
HAVING COUNT(rental_id) >= 30;

-- Jimmy wants to understand how come certain customers are not renting much. To do so he needs to find which customers have less than 15 rentals so he can reach out to them 

SELECT customer_id, COUNT(rental_id) AS total_rentals
FROM rental 
GROUP BY (customer_id) 
HAVING COUNT(rental_id) <= 15;

-- Looking for largest total payment amounts per customer profile

SELECT customer_id, SUM(amount) AS total_payments
FROM payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC 
LIMIT 10;

-- Jimmy wants to see if our longest films tend to be the most expensive to rent. To do so he needs to find all film titles along with their lengths and rental rates and sort them from longest to shortest
SELECT title, length, rental_rate
FROM film
ORDER BY length DESC;

-- Jimmy wants to list each film in inventory. He wants title, description, store_id and inventory_id

SELECT title, description, inventory.store_id, inventory.inventory_id
FROM film 
INNER JOIN 
	Inventory ON film.film_id = inventory.film_id;
-- Or this..
SELECT 
	inventory_id,
	store_id,
	film.title,
	film.description
FROM inventory
	INNER JOIN film 
		ON inventory.film_id = film.film_id;

-- We want to find out the number of films that each actor appeared in 
SELECT 
	Actor.first_name,
	Actor.last_name,
	COUNT(film_actor.film_id) AS number_of_films
FROM actor
	LEFT JOIN film_actor ON actor.actor_id = film_actor.actor_id
GROUP BY 
	Actor.first_name,
	Actor.last_name;

-- Jimmy wants to know how many actors are listed for each film title
SELECT 
Title,
COUNT(film_actor.actor_id) AS total_actors
FROM film
LEFT JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY 
film.title;
