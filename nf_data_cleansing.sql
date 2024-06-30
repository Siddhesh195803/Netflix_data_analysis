--handling foreign characters
/*This did not work for some reason*/
--remove duplicates
select * from netflix_raw where title = 'Esperando La Carroza'

select title, type from(
select title,type, count(*) as cnt from netflix_raw group by title,type
having count(*) > 1) as sb

with cte as (
select *,
ROW_NUMBER() over (partition by title, type order by show_id) as rn
from 
netflix_raw)
select show_id, type, title, 
cast(date_added as date) --data type conversions for date_added
as date_added, release_year
,rating , case when duration is null then rating else duration end as duration , description 
into netflix
from cte 
where rn = 1 
;


select * from netflix;

--new table for listed_in, director, country, cast

select show_id, trim(value) as director
into netflix_directors
from netflix_raw
cross apply string_split(director, ',')
order by show_id;

select show_id, trim(value) as genre
into netflix_genre
from netflix_raw
cross apply string_split(listed_in, ',')
order by show_id

select show_id, trim(value) as cast
into netflix_cast
from netflix_raw
cross apply string_split(cast, ',')
order by show_id
select * from netflix_cast;


--populate missing values in country, duration columns
select * from netflix_raw where country is null;
insert into netflix_country
select show_id, m.country
from netflix_raw nr 
inner join

(select director,country from netflix_country nc 
join netflix_directors nd on nd.show_id = nc.show_id 
group by director,country  ) m
on nr.director =  m.director
where nr.country is null;

select * from netflix_country where show_id is null;

select * from netflix_raw where duration is null

select * from netflix_raw where rating like '% min'