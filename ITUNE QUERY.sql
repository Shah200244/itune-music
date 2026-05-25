select * from album

select * from invoice_line

select * from playlist_track

select * from media_type

select * from playlist

select * from track

select * from genre

select * from employee

select * from artist

select * from customer

CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    title VARCHAR(100),
    reports_to INT,
    levels VARCHAR(10),
    birthdate TIMESTAMP,
    hire_date TIMESTAMP,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    fax VARCHAR(50),
    email VARCHAR(100)
);

select * from employee

select * from genre

create table invoice(
invoice_id int, 
customer_id int,
invoice_date timestamp,
billing_address varchar(60),
billing_city varchar(50),
billing_state varchar(40),
billing_country varchar(60),
billing_postal_code var

)
select * from employee
select * from invoice

--customer who spent most money
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i 
ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

--Average customer lifetime value
SELECT 
    AVG(total_spent) AS avg_customer_lifetime_value
FROM (
    SELECT 
        customer_id,
        SUM(total) AS total_spent
    FROM invoice
    GROUP BY customer_id
) AS customer_value;

--Repeat customers vs one-time customers
SELECT 
    CASE 
        WHEN purchase_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS total_customers
FROM (
    SELECT 
        customer_id,
        COUNT(invoice_id) AS purchase_count
    FROM invoice
    GROUP BY customer_id
)
GROUP BY customer_type;

--country generates the most revenue per customer
SELECT 
    billing_country,
    ROUND(SUM(total) / COUNT(DISTINCT customer_id),2) AS revenue_per_customer
FROM invoice
GROUP BY billing_country
ORDER BY revenue_per_customer DESC;

--customers haven't made a purchase in the last 6 months
select c.first_name, c.last_name,
MAX(i.invoice_date) as last_purchase
from customer as c 
join invoice as i 
on c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING MAX(i.invoice_date) < CURRENT_DATE - INTERVAL '6 months'

--the monthly revenue trends for the last two years
SELECT 
    DATE_TRUNC('month', invoice_date) AS month,
    SUM(total) AS monthly_revenue
FROM invoice
GROUP BY month
ORDER BY month;

--the average value of an invoice 
select  round(avg(total),2) as average_value
from invoice

--revenue contribution by each sales representative 
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    SUM(i.total) AS total_revenue
FROM employee e
JOIN customer c 
ON e.employee_id = c.support_rep_id
JOIN invoice i 
ON c.customer_id = i.customer_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_revenue DESC;

--months or quarters have peak music sales
select 
extract('month' from invoice_date) as month,
sum(total) as total_sales
FROM invoice
GROUP BY month
ORDER BY total_sales DESC;

--tracks generated the most revenue
SELECT 
    t.track,
    t.name AS track_name,
    sum( il.unit_price::numeric * 
        il.quantity::numeric) AS revenue
FROM track as t
JOIN invoice_line as il 
ON t.track = il.track_id
GROUP BY t.track, t.name
ORDER BY revenue DESC;

--albums or playlists are most frequently included in purchases
SELECT 
    a.title,
    COUNT(il.inovice_line_id) AS total_purchases
FROM album as a
JOIN track as t 
ON a.album_id = t.album_id
JOIN invoice_line as il 
ON t.track = il.track_id
GROUP BY a.title
ORDER BY total_purchases DESC;

--tracks or albums that have never been purchased
SELECT 
    t.track,
    t.name
FROM track t
LEFT JOIN invoice_line il 
ON t.track = il.track_id
WHERE il.track_id IS NULL;

--the average price per track across different genres
SELECT 
    g.name AS genre,
    ROUND(AVG(CAST(t.unit_price AS NUMERIC)),2) AS avg_price
FROM genre g
JOIN track t 
ON g.genre = t.genre_id
GROUP BY g.name
ORDER BY avg_price DESC;

--Tracks count per genre
SELECT 
    g.name AS genre,
    COUNT(t.track) AS total_tracks
FROM genre g
JOIN track t 
ON g.genre= t.genre_id
GROUP BY g.name
ORDER BY total_tracks DESC;

--top 5 highest-grossing artists
SELECT 
    ar.name AS artist,
    SUM(il.unit_price::numeric * 
        il.quantity::numeric) AS revenue
FROM artist ar
JOIN album a 
ON ar.artist_id = a.artist_id
JOIN track t 
ON a.album_id = t.album_id
JOIN invoice_line il 
ON t.track = il.track_id
GROUP BY ar.name
ORDER BY revenue DESC
LIMIT 5;

--Most popular genres by tracks sold
SELECT 
    g.name AS genre,
    SUM(il.quantity::numeric) AS tracks_sold
FROM genre g
JOIN track t 
ON g.genre = t.genre_id
JOIN invoice_line il 
ON t.track = il.track_id
GROUP BY g.name
ORDER BY tracks_sold DESC;

--music genres are most popular in total revenue
SELECT 
    g.name AS genre,
    SUM(il.unit_price :: numeric * il.quantity::numeric) AS revenue
FROM genre g
JOIN track t 
ON g.genre = t.genre_id
JOIN invoice_line il 
ON t.track = il.track_id
GROUP BY g.name
ORDER BY revenue DESC;

--genres more popular in specific countries
SELECT 
    i.billing_country,
    g.name AS genre,
    SUM(il.quantity :: numeric) AS total_sales
FROM invoice i
JOIN invoice_line il 
ON i.invoice_id = il.invoice_id
JOIN track t 
ON il.track_id = t.track
JOIN genre g 
ON t.genre_id = g.genre
GROUP BY i.billing_country, g.name
ORDER BY i.billing_country, total_sales DESC;

--employees (support representatives) are managing the highest-spending customers
SELECT 
    e.first_name,
    e.last_name,
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    SUM(i.total) AS total_spent
FROM employee e
JOIN customer c 
ON e.employee_id = c.support_rep_id
JOIN invoice i 
ON c.customer_id = i.customer_id
GROUP BY e.first_name, e.last_name,
         c.first_name, c.last_name.
ORDER BY total_spent DESC;

--the average number of customers per employee
SELECT 
    AVG(customer_count) AS avg_customers_per_employee
FROM (
    SELECT 
        support_rep_id,
        COUNT(customer_id) AS customer_count
    FROM customer
    GROUP BY support_rep_id
)

--employee regions bring in the most revenue
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    c.country,
    SUM(i.total::numeric) AS total_revenue
FROM employee e
JOIN customer c
ON e.employee_id = c.support_rep_id
JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY 
    e.employee_id,
    e.first_name,
    e.last_name,
    c.country
ORDER BY total_revenue DESC;

--countries or cities have the highest number of customers
SELECT 
    country,
    COUNT(customer_id) AS total_customers
FROM customer
GROUP BY country
ORDER BY total_customers DESC;

--revenue vary by region
SELECT 
    billing_country,
    SUM(total) AS revenue
FROM invoice
GROUP BY billing_country
ORDER BY revenue DESC;

--any underserved geographic regions (high users, low sales)
SELECT 
    c.country,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COALESCE(SUM(i.total::numeric),0) AS total_revenue
FROM customer c
LEFT JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY total_customers DESC, total_revenue DESC;


--distribution of purchase frequency per customer
SELECT 
    customer_id,
    COUNT(invoice_id) AS purchase_frequency
FROM invoice
GROUP BY customer_id
ORDER BY purchase_frequency DESC;


--the average time between customer purchases
WITH purchase_dates AS (
    SELECT 
        customer_id,
        invoice_date,
        LAG(invoice_date) OVER (
            PARTITION BY customer_id 
            ORDER BY invoice_date
        ) AS previous_purchase
    FROM invoice
)
SELECT 
    customer_id,
    AVG(invoice_date - previous_purchase) AS avg_days_between_purchases
FROM purchase_dates
WHERE previous_purchase IS NOT NULL
GROUP BY customer_id;

--Customers purchasing from multiple genres
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT g.genre) AS genres_purchased
FROM customer c
JOIN invoice i 
ON c.customer_id = i.customer_id
JOIN invoice_line il 
ON i.invoice_id = il.invoice_id
JOIN track t 
ON il.track_id = t.track
JOIN genre g 
ON t.genre_id = g.genre
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT g.genre) > 1;

--the most common combinations of tracks purchased together
SELECT 
    il1.track_id AS track_1,
    il2.track_id AS track_2,
    COUNT(*) AS times_purchased_together
FROM invoice_line il1
JOIN invoice_line il2
ON il1.invoice_id = il2.invoice_id
AND il1.track_id < il2.track_id
GROUP BY il1.track_id, il2.track_id
ORDER BY times_purchased_together DESC;

--pricing patterns that lead to higher or lower sales
SELECT 
    mt.name AS media_type,
    SUM(il.unit_price :: numeric * il.quantity :: numeric) AS revenue
FROM media_type mt
JOIN track t 
ON mt.media_type = t.media_type_id
JOIN invoice_line il 
ON t.track = il.track_id
GROUP BY mt.name
ORDER BY revenue DESC;

--Media types increasing or decreasing in usage
SELECT 
    mt.name AS media_type,
    DATE_TRUNC('year', i.invoice_date) AS year,
    COUNT(il.inovice_line_id) AS usage_count
FROM media_type mt
JOIN track t 
ON mt.media_type = t.media_type_id
JOIN invoice_line il 
ON t.track = il.track_id
JOIN invoice i 
ON il.invoice_id = i.invoice_id
GROUP BY mt.name, year
ORDER BY mt.name, year;