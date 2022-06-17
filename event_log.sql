select count(*)
from event.log;

select *
from event.log;

##### USER #####
# DAU
select substr(event_time, 1, 10) as 'date',
	count(distinct user_id) as DAU
from event.log
group by 1
order by 1;

# WAU
select week(event_time) as 'week',
	count(distinct user_id) as WAU
from event.log
group by 1
order by 1;

# MAU
select substr(event_time, 1, 7) as YM,
	count(distinct user_id) as MAU
from event.log
group by 1
order by 1;

# ARPPU
-- event_type= purchase
-- Daily
select substr(event_time, 1, 10) as 'date',
	count(distinct user_id) as PU,
	sum(price) as rev,
    sum(price)/ count(distinct user_id) as ARPPU
from event.log
where event_type= 'purchase'
group by 1
order by 1;
-- Weekly
select week(event_time) as 'week',
	count(distinct user_id) as PU,
	sum(price) as rev,
    sum(price)/ count(distinct user_id) as ARPPU
from event.log
where event_type= 'purchase'
group by 1
order by 1;
-- Monthly
select substr(event_time, 1, 7) as YM,
	count(distinct user_id) as PU,
	sum(price) as rev,
    sum(price)/ count(distinct user_id) as ARPPU
from event.log
where event_type= 'purchase'
group by 1
order by 1;

# ARPU
-- total revenue / active users
-- Daily
select substr(event_time, 1, 10) as 'date',
	count(distinct user_id) as DAU,
    sum(price) as rev,
    sum(price)/ count(distinct user_id) as ARPU
from event.log
group by 1
order by 1;
-- Weekly
select week(event_time) as 'week',
	count(distinct user_id) as WAU,
    sum(price) as rev,
    sum(price)/ count(distinct user_id) as ARPU
from event.log
group by 1
order by 1;
-- Monthly
select substr(event_time, 1, 7) as YM,
	count(distinct user_id) as MAU,
    sum(price) as rev,
    sum(price)/ count(distinct user_id) as ARPU
from event.log
group by 1
order by 1;

# Conversion Rate
-- view-> cart-> purchase
-- view user
with view_user as
(select substr(event_time, 1, 10) as event_date,
	user_id
from event.log
where event_type= 'view'),
-- cart user
cart_user as
(select substr(event_time, 1, 10) as event_date,
	user_id
from event.log
where event_type= 'cart'),
-- purchse user
paid_user as
(select substr(event_time, 1, 10) as event_date,
	user_id
from event.log
where event_type= 'purchase')
-- Users Count
-- select a.event_date,
-- 	count(distinct a.user_id) as view_cnt,
--     count(distinct b.user_id) as cart_cnt,
--     count(distinct c.user_id) as purchase_cnt
-- from view_user as a
-- 	left join cart_user as b
-- 		on a.user_id= b.user_id
-- 	left join paid_user as c
-- 		on a.user_id= c.user_id
-- 			and b.user_id= c.user_id
-- group by 1
-- order by 1;

select a.event_date,
	count(distinct b.user_id)/ count(distinct a.user_id)* 100 as view_to_cart,
    count(distinct c.user_id)/ count(distinct b.user_id)* 100 as cart_to_purchase
from view_user as a
	left join cart_user as b
		on a.user_id= b.user_id
	left join paid_user as c
		on a.user_id= c.user_id
			and b.user_id= c.user_id
group by 1
order by 1;

# Retention Rate (Monthly)
select month(a.event_time) as 'month',
	count(distinct a.user_id) as AU_current_month,
    count(distinct b.user_id) as AU_month_before
from
(select event_time, user_id
from event.log) as a
	left join (select event_time, user_id
				from event.log) as b
		on a.user_id= b.user_id
			and month(a.event_time)= month(b.event_time)- 1
group by 1
order by 1;

# Re_Purchase Rate (Monthly)
select month(a.event_time) as 'month',
	count(distinct a.user_id) as PU_current_month,
    count(distinct b.user_id) as PU_month_before
from
(select event_time, user_id
from event.log
where event_type= 'purchase') as a
	left join (select event_time, user_id
				from event.log
                where event_type= 'purchase') as b
		on a.user_id= b.user_id
			and month(a.event_time)= month(b.event_time)- 1
group by 1
order by 1;

# Daily Event, User, Session Count
select substr(event_time, 1, 10) as 'date',
	count(event_time) as event_cnt,
    count(distinct user_id) as DAU,
    count(distinct user_session) as session_cnt,
	count(event_time)/ count(distinct user_id) as events_per_user,
    count(distinct user_session)/ count(distinct user_id) as sessions_per_user,
    count(event_time)/ count(distinct user_session) as events_per_session
from event.log
group by 1
order by 1;

# Weekly Event, User, Session Count
select week(event_time) as 'week',
	count(event_time) as event_cnt,
    count(distinct user_id) as WAU,
    count(distinct user_session) as session_cnt,
	count(event_time)/ count(distinct user_id) as events_per_user,
    count(distinct user_session)/ count(distinct user_id) as sessions_per_user,
    count(event_time)/ count(distinct user_session) as events_per_session
from event.log
group by 1
order by 1;

# Monthly Event, User, Session Count
select substr(event_time, 1, 7) as YM,
	count(event_time) as event_cnt,
    count(distinct user_id) as MAU,
    count(distinct user_session) as session_cnt,
	count(event_time)/ count(distinct user_id) as events_per_user,
    count(distinct user_session)/ count(distinct user_id) as sessions_per_user,
    count(event_time)/ count(distinct user_session) as events_per_session
from event.log
group by 1
order by 1;

##### PRODUCT #####
# 가장 많이 조회된 상품
with most_view as
(select product_id,
    count(user_id) as view_cnt
from event.log
-- where event_type= 'view'
group by 1
order by 2 desc),
-- 상위 5개 상품들의 구매 횟수
sold_cnt as
(select product_id,
	count(user_id) as pay_cnt
from event.log
where event_type= 'purchase'
	and product_id in (select product_id
					from most_view)
group by 1
order by 2 desc)
-- 위 상품들의 구매 전환율
-- view -> purchase
select a.product_id,
	a.view_cnt,
    b.pay_cnt,
    b.pay_cnt/ a.view_cnt* 100 as conversion_rate
from most_view as a
	left join sold_cnt as b
		on a.product_id= b.product_id
order by 4 desc;

# 매출액 하위 5개 상품
with low_5 as
(select product_id,
	sum(price) as rev
from event.log
where event_type= 'purchase'
group by 1
order by 2 asc
limit 5)
-- 이 상품들의 브랜드
select distinct brand
from event.log
where product_id in (select product_id from low_5);

# 제품 월별 판매량 순위 TOP5
with monthly_rnk as
(select substr(event_time, 1, 7) as YM,
	product_id,
    count(user_id) as pay_cnt,
    row_number() over(partition by substr(event_time, 1, 7) order by count(user_id) desc) as rnk
from event.log
where event_type= 'purchase'
group by 1, 2)

select *
from monthly_rnk
where rnk between 1 and 5;

# 특정 제품을 구매한 고객이 구매한 상품
-- 월별 판매 순위
with monthly_rnk as
(select substr(event_time, 1, 7) as YM,
	product_id,
    count(user_id) as pay_cnt,
    row_number() over(partition by substr(event_time, 1, 7) order by count(user_id) desc) as rnk
from event.log
where event_type= 'purchase'
group by 1, 2),
-- 월별 최다 판매 상품
monthly_top as
(select ym, product_id, pay_cnt
from monthly_rnk
where rnk= 1),
-- 이 상품들을 구매한 고객
user_list as
(select distinct user_id
from event.log
where event_type= 'purchase'
	and product_id in (select product_id from monthly_top))
-- 이 상품들을 구매한 고객이 구매한 물품 순위
select product_id,
	count(user_id) as pay_cnt
from event.log
where event_type= 'purchase'
	and user_id in (select user_id from user_list)
group by 1
order by 2 desc;

# 월별 판매 금액 순위 TOP5
with monthly_rnk as
(select substr(event_time, 1, 7) as YM,
	product_id,
    sum(price) as rev,
    row_number() over(partition by substr(event_time, 1, 7) order by sum(price) desc) as rnk
from event.log
where event_type= 'purchase'
group by 1, 2)

select *
from monthly_rnk
where rnk between 1 and 5;