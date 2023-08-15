-- Q1.Who is the senior most employee based on the job title?

select Concat(last_name,first_name) as senior_most_employee 
from employee
order by levels desc
limit 1;

-- Q2.Which countries have the most invoices?

select count(*) as count_country,billing_country  
from invoice
group by billing_country 
order by count_country  desc
limit 1;


-- Q3.What are the top 3 value of total invoice?

select total
from invoice
order by total desc
limit 3;


-- Q4.Which City has the best customer? We would like to throw a promotional music
-- music festival in the city we made most money.
-- Write a query that returns the city that has the highest sum of invoice totals.
-- Return both the city names & sum of all invoice totals

select sum(total) as invoice_total,billing_city
from invoice
group by billing_city
order by invoice_total desc;

-- Q5.Who is the best customer? The customer who has spent the most money will be declared 
-- as the best customer. write a query that returns the person who has spent most money.

select customer_id,first_name,last_name,sum(total) as total_cost
from customer c
join invoice i using(customer_id)
group by customer_id
order by total_cost desc
limit 1;

-- Q6.Write a query to return the email,first name,last name, and genre of all rock music listeners
-- return your list ordered alphabetically by email starting with A.

select distinct email,first_name,last_name 
from customer c 
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
where track_id in (
	select track_id 
	from track
	join genre using(genre_id)
	where genre.name like 'Rock'
)
order by email;

-- Q7.Invite the artist who have written the most rock music in our data set.
-- Write a query that returns the artist name and total track count of top 10 rock bands.

select ar.name,count(*) as total_track_count
from track t
join album a on t.album_id = a.album_id
join artist ar on ar.artist_id = a.artist_id
join genre g on g.genre_id = t.genre_id 
where g.name like 'Rock'
group by ar.name
order by total_track_count desc
limit 10;

-- Q8.Return all the track names that have song length longer than the avg song length
-- Return the name and milliseconds for each track. Order by the song length with the longest song listed first.

select name,milliseconds  
from track
where milliseconds >
	(
	select avg(milliseconds) 
	from track
	)
order by milliseconds desc;

-- Q9.Find how much amount spent by each customer on artists? 
-- Write a query to return customer name, artist name and total spent.

with best_selling_artist as (
	select ar.artist_id as artist_id, ar.name as artist_name,
	sum(il.unit_price  * il.quantity) as total_spent
	from invoice_line il
	join track t on t.track_id = il.track_id
	join album al on al.album_id = t.album_id
	join artist ar on ar.artist_id = al.artist_id
	group by 1
	order by 3 desc
	limit 1	
)

select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
sum(il.unit_price * il.quantity) as amount_spent
from invoice i
join customer c on i.customer_id = c.customer_id 
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album al on al.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = al.artist_id
group by 1,2,3,4
order by 5 desc ;

-- Q10.We want to find out most popular music genre for each country. We determines the most popular genre as 
-- the genre with the highest amount of purchase. Write a query that returns each country along with top genre.
-- for countries where the maximum number of purchase is shared return all genres.

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

-- Q11 Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount. 

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1



