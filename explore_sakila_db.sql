-- Use Sakila Database --
use sakila;

-- 1a. Extract first and last actor names --
select 
	first_name,
    last_name
from 
	actor;
    
-- turn safety off --
set sql_safe_updates = 0;    

-- 1b. Add a column called 'Actor Name' --
alter table actor
add actor_name varchar(50);

update actor set actor_name = UPPER(actor_name); -- set the letters to uppercase

-- update the parameters for the actor_name column --
update actor set actor_name = concat(first_name, ' ', last_name);

-- 2a. query for ID number, first name, and last name for actors named Joe --
select 
	actor_id,
    first_name,
    last_name
from actor
where first_name = 'Joe';

-- 2b. query for ID number, first name, and last name for actors whose last name contains 'GEN' --
select 
    first_name,
    last_name
from actor
where last_name = '%GEN%';

-- 2c. query for last name and first name for actors whose last names contain 'LI' --
select 
    last_name,
	first_name
from actor
where last_name like ('%li%');

-- 2d. display country_id and country for Afghanistan, Bangladesh, China --
select 
	country_id,
    country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. keep a description of each actor --
alter table actor
add `description` blob;

-- 3b. Delete description column --
alter table actor
drop column `description`;

-- 4a. How many actors for each last name? --
select 
	last_name,
    count(last_name) as 'Number of actors'
from actor
group by last_name;

-- 4b. How many actors have the same last names?
select 
	last_name,
    count(last_name) as 'Number of actors'
from actor
group by last_name
having count(last_name) > 1;


-- 4c. revise the name 'Groucho Williams' to 'Harpo Williams' --
update actor
set 
	first_name = 'HARPO',
    actor_name = 'HARPO WILLIAMS'
where actor_name = 'GROUCHO WILLIAMS';

-- 4d. Change back to 'Groucho Williams' --
update actor
set 
	first_name = 'GROUCHO',
    actor_name = 'GROUCHO WILLIAMS'
where actor_name = 'HARPO WILLIAMS';

-- turn safety off --
set sql_safe_updates = 1;

-- 5. Query to recreate the schema of the address table --
show create table address;

-- 6a. Display first and last names, address of each staff member --
select 
    s.first_name,
    s.last_name,
    a.address
from staff as s
join address as a on s.staff_id = a.address_id; 

-- 6b. Amount rung up by each staff member --
select 
    s.first_name,
    s.last_name,
    sum(p.amount) as 'Total'
from staff as s
join payment as p on s.staff_id = p.staff_id
group by p.staff_id;

-- 6c. Films and number of actors --
select
	f.title,
    count(fa.actor_id) as 'No_of_actors'
from film as f
inner join film_actor as fa on f.film_id = fa.film_id
group by f.title;

-- 6d. Inventory of 'Hunchback Impossible' --
select
    count(i.film_id) as 'No_of_copies'
from film as f
join inventory as i on f.film_id = i.film_id -- using join --
where f.title = 'Hunchback Impossible'
group by f.title;

select 
	count(film_id) as 'No_of_copies'
from inventory
where film_id in -- using subquery --
	(select film_id
    from film
    where title = 'Hunchback Impossible');

-- 6e. List the total paid by each customer, sorted by last name --
select 
    c.first_name,
    c.last_name,
    sum(p.amount) as 'Total payment'
from payment as p
join customer as c on p.customer_id = c.customer_id  
group by p.customer_id
order by last_name asc;  

-- 7a. Titles of movies that start with the letters K and the letter Q, whose language is English --
select 
	title as 'English movies'
from film
where language_id in 
	(select 
		language_id
	from `language`
	where `name` = 'English'
	)
and (title like 'K%' or title like 'Q%'); -- movies whose titles start with 'K' or 'Q'--

-- 7b. Who are in the cast of the film 'Alone Trip'? --
select 
	actor_name as 'Cast of Alone Trip' -- list of actors with --
from actor
where actor_id in -- actor_id associated with --
	(select 
		actor_id 
	from film_actor
	where film_id in -- the film_id associated with --
		(select 
			film_id
		from film
		where title = 'Alone Trip') -- the movie entitled title 'Alone Trip' --
);

-- 7c. Names and email addresses of all Canadian customers --
select 
    cu.first_name,
    cu.last_name,
    cu.email
from country as co
join city as ci on ci.country_id = co.country_id
join address as ad on ad.city_id = ci.city_id
join store as st on st.address_id = ad.address_id
join customer as cu on st.store_id = cu.store_id
where co.country = 'Canada';

-- 7d. List films categorised as 'family' films --
select 
	title -- list movies with --
from film
where film_id in -- film_id associated with --
	(select 
	film_id
	from film_category
	where category_id in -- category_id associated with --
		(select 
		category_id
		from category
		where `name` = 'Family')
); -- films classified as 'family films' --

-- 7e. What are the most frequently rented movies? --
select 
    title,	
    count(film.film_id) as 'Rent count'
from film 
join inventory on film.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
group by film.film_id
order by count(film.film_id) desc; -- 'desc' = descending order

-- 7f. How much business (in dollars) did each store brought in? --
select
	st.store_id,
	sum(p.amount) as 'Total business ($)'
from payment as p
join staff as sf on p.staff_id = sf.staff_id
join store as st on sf.store_id = st.store_id
group by p.staff_id;

-- 7g. Display the store locations --
select 
	st.store_id,
    ci.city,
    co.country
from store as st
join address as a on st.address_id = a.address_id
join city as ci on a.city_id = ci.city_id
join country as co on ci.country_id = co.country_id;

-- 7h. Top 5 genres in gross revenue --
select 
	cat.`name`,
    sum(p.amount)
from category as cat
join film_category as fc on cat.category_id = fc.category_id
join inventory as i on fc.film_id = i.film_id
join rental as r on i.inventory_id = r.inventory_id
join payment as p on r.rental_id = p.rental_id
group by cat.`name`
order by sum(p.amount) desc -- arrange in descending order --
limit 5; -- get the top 5 --

-- 8a. create view for top five genres (7h) --
create view top_five_genres as
select 
	cat.`name`,
    sum(p.amount)
from category as cat
join film_category as fc on cat.category_id = fc.category_id
join inventory as i on fc.film_id = i.film_id
join rental as r on i.inventory_id = r.inventory_id
join payment as p on r.rental_id = p.rental_id
group by cat.`name`
order by sum(p.amount) desc -- arrange in descending order --
limit 5; -- get the top 5 --

-- 8b. display the top_five_genres view --
select * from top_five_genres;

-- 8c. delete the top_five_genres view --
drop view top_five_genres;