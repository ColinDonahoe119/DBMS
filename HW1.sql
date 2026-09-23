use hw;

-- Number 1:
select category, avg(price) as avg_price
from pastries
group by category;

-- Number 2:
select experience_level, count(baristaID) as num_baristas
from baristas
group by experience_level;

-- Number 3:
select city, count(shopID) as num_shops
from shops
group by city

-- Number 4:
select category, max(price) as highest_price
from pastries
group by category;

-- Number 5:
select shopID, count(pastryID) as num_added
from offers
group by shopID;

-- Number 6:
select name, category, price
from pastries
where (category, price) in
    (select category, max(price)
     from pastries
     group by category);
     
-- Number 7:
select distinct shopID 
from offers
natural join pastries
where price > (
	select avg(price)
    from pastries)
    
-- Number 8:
select shopID, pastryID
from offers
where date_added <= all 
	(select min(date_added) from offers)
    
-- Number 9:
select shopID
from offers
group by shopId
having count(shopID) >= all(
	select count(shopID)
    from offers
    group by shopID);
    
-- Number 10:
select name
from baristas
where baristaID in
    (select baristaID
     from employs
     where shopID in
        (select shopID
         from shops
         where city = 'Seattle'));
    
