use zomato;
create table goldusers_signup(userid integer, gold_signup_date date );
insert into goldusers_signup(userid,gold_signup_date) values (1,'2017-09-12');
insert into goldusers_signup(userid,gold_signup_date) values (3,'2017-04-21'); 
select * from goldusers_signup; 
-- drop table goldusers_signup; 
CREATE TABLE users(userid integer,signup_date date);
INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');
CREATE TABLE sales(userid integer,created_date date,product_id integer);
INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);
select * from sales;
CREATE TABLE product(product_id integer,product_name text,price integer); 
INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

 
 -- what is the total amount each customer spent on zomato ?
select s.userid, s.product_id, sum(p.price) as total_money_spent from sales s join product p on s.product_id=p.product_id group by s.userid;

-- how many days has each customer visited zomato ?
select userid, count(distinct(created_date)) as distinct_days from sales group by userid;

-- what was the first product purchased by each customer ??
select * from (select * , rank() over (partition by userid order by created_date) rnk from sales) a where rnk=1; 

-- what is most purchased item on menu & how many times was it purchased by all customers ?
select s.userid, count(distinct(s.product_id)) as cnt, p.product_name from sales s join product p where s.product_id=s.product_id
group by s.userid
order by cnt desc;

-- which item was most popular for each customer?
select * from
(select *,rank() over(partition by userid order by cnt desc) rnk from
(select userid,product_id,count(product_id) cnt from sales group by userid,product_id)a)b
where rnk =1;

-- which item was purchased first by customer after they become a member ?
select * from 
(select c.*, rank() over (partition by userid order by created_date)rnk from (select s.userid,s.created_date,s.product_id,g.gold_signup_date from sales s join goldusers_signup g on s.userid=g.userid and created_date>=gold_signup_date)c)d where rnk=1; 

-- which item was purchased just before customer became a member?
select * from
(select c.*,rank() over (partition by userid order by created_date desc ) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid and created_date<=gold_signup_date) c)d where rnk=1;

-- rnk all transaction of the customers
select*,rank() over (partition by userid order by created_date ) rnk from sales;

-- rank all transaction for each member whenever they are zomato gold member for every non gold member transaction mark as na
select e.*,
case when rnk=0
then 'na' 
else rnk
end as rnkk
from
(select c.*,case when gold_signup_date is null then 0  else rank() over (partition by userid order by created_date desc) end as rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a left join
goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date)c)e;

-- what is total orders and amount spent for each member before they become a member ?
select userid,count(created_date) order_purchased,sum(price) total_amt_spent from
(select c.*,d.price from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid and created_date<=gold_signup_date) c inner join product d on c.product_id=d.product_id)e
group by userid;
