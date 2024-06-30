/*
1)For each director count the no. of movies and tv shows created by them in seperate columns for 
directors who have created tv shows and movies both
*/



(
select nd.director director, 
COUNT(DISTINCT CASE WHEN n.type = 'Movie' then n.show_id end) as Movie ,
COUNT(DISTINCT CASE WHEN n.type = 'TV Show' then (n.show_id) end) as TV
from netflix n 
join netflix_director nd 
on n.show_id = nd.show_id
group by  nd.director 
having COUNT(distinct n.type) >1
) 


/*
2) Which country has highest number of comedy movies?
*/

select  top 1 count(c.show_id) no_of_comedy_movies, c.country from netflix_genre g 
join netflix_country c on g.show_id= c.show_id
where genre in (
'Comedies')
group by  c.country 
order by count(c.show_id) desc


/*
3) For each year (as per date added to netflix), which director has maximum number of movies
released
*/
with cte as(
SELECT nd.director,
YEAR(date_added) as date_year
,count(n.show_id) as no_of_movies
from netflix n
join netflix_director nd on
nd.show_id = n.show_id
where n.type = 'Movie'
group by nd.director,  YEAR(date_added) )

,
final as (
select * 
,
ROW_NUMBER() over(partition by date_year order by no_of_movies desc, director ) as rn

from cte)

select director, date_year from final where rn = 1
;

/*
4) What is the avg duration of movie in each genre
*/

with dur_cte as (
select (cast(duration as int)) as dur, genre as gen from (
SELECT 
SUBSTRING(duration, 1, CHARINDEX(' ', duration + ' ') - 1) AS duration
,g.genre as genre
FROM netflix n 
join netflix_genre g 
on n.show_id = g.show_id
where n.type = 'Movie'
) as s)
select avg(dur), gen  from dur_cte
group by gen
order by gen


/*
5) Find the list of directors who have created horror and comedy movies both.
Display director names along with number of comedy and horror movies directed by them
*/


with net as
(select show_id, type 
from netflix 
where type = 'Movie'),

dir as
(select show_id, director from
netflix_director ),

gen as(
select show_id, genre from
netflix_genre )

select dir.director ,
--COUNT(DISTINCT CASE WHEN n.type = 'Movie' then n.show_id end) as Movie 
COUNT(DISTINCT CASE WHEN gen.genre = 'Horror Movies' THEN net.show_id END) AS Horror_Count,
COUNT(DISTINCT CASE WHEN gen.genre = 'Comedies' THEN net.show_id END) AS Comedies_Count
from dir 

join net on dir.show_id = net.show_id
join gen on net.show_id = gen.show_id
where gen.genre IN ('Horror Movies','Comedies' )

group by dir.director
having COUNT(DISTINCT CASE WHEN gen.genre = 'Horror Movies' THEN net.show_id END) >=1
and 
COUNT(DISTINCT CASE WHEN gen.genre = 'Comedies' THEN net.show_id END) >=1;