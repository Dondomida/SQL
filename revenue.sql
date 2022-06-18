# 1. 국가별, 상품별 구매자 수 및 매출액
select distinct country
from
(select country,
	description,
    stockcode,
    count(distinct customerid) as pu,
    sum(quantity* unitprice) as revenue
from challenge.final
group by 1, 2) as a;

-- 국가별
select distinct country,
	count(distinct customerid) as pu,
    sum(quantity* unitprice) as rev
from challenge.final
group by 1;
-- 상품별
select distinct description,
	count(distinct customerid) as pu,
    sum(quantity* unitprice) as rev
from challenge.final
group by 1;

# 2. 특정 상품 구매자가 많이 구매한 상품?
-- 가장 많이 판매된 2개 상품
-- 84077, 85123A
select description,
	stockcode,
    sum(quantity) as sold_cnt
from challenge.final
group by 1
order by 3 desc
limit 2;

-- 이 상품들을 모두 구매한 구매자가 구매한 상품 10개
with users as
(select distinct customerid
from challenge.final
where stockcode= '84077'
	and customerid in (select distinct customerid
						from challenge.final
                        where stockcode= '85123A'))
                        
select distinct description, stockcode,
	sum(quantity)
from challenge.final
where customerid in (select * from users)
group by 1
order by 3 desc
limit 10;

# 3. 국가별 재구매율 (연도별)
select a.country,
	count(distinct b.customerid)/ count(distinct a.customerid) as retention_rate
from
(select country, customerid, invoicedate
from challenge.final) as a
	left join
			(select country, customerid, invoicedate
            from challenge.final) as b
		on a.customerid= b.customerid
			and year(a.invoicedate)= year(b.invoicedate)- 1
group by 1;

# 4. 국가별 첫 구매 이후 이탈하는 고객의 비중
with user_cnt as
(select country,
	customerid,
	count(distinct invoicedate) as order_day
from challenge.final
group by 1, 2)

select country,
	sum(case when order_day= 1 then 1 else 0 end)/ count(distinct customerid) as bounce_rate
from user_cnt
group by 1;

# 5. 판매 수량이 20%이상 증가한 상품
-- 2010년 판매 수량
with sold_10 as
(select description,
	stockcode,
    sum(quantity) as total_sold
from challenge.final
where year(invoicedate)= 2010
group by 1),

-- 2011년 판매수량
sold_11 as
(select description,
	stockcode,
    sum(quantity) as total_sold
from challenge.final
where year(invoicedate)= 2011
group by 1)

select a.description,
	a.stockcode,
    a.total_sold as quantity_10,
    b.total_sold as quantity_11,
    round(b.total_sold/ a.total_sold, 2) as increase_rate
from sold_10 as a
	left join sold_11 as b
		on a.description= b.description
			and a.stockcode= b.stockcode
where b.total_sold/ a.total_sold>= 0.2
	and a.description like '%WRAP%'
order by 5 desc;

# 6. 신규 / 기존 고객의 2011년 월별 매출액
-- 최초구매== 2011 -> 신규
-- 최초구매== 2010 -> 기존

# 기존, 신규 구분
with users as
(select customerid,
	case when year(min_date)= 2010 then 'old' else 'new' end as userType
from
# 최초구매일
(select customerid,
	min(invoicedate) as min_date
from challenge.final
group by 1) as f)

select substr(invoicedate, 1, 7) as YM,
	usertype,
    sum(quantity* unitprice) as rev
from challenge.final as a
	left join users as b
		on a.customerid= b.customerid
where year(invoicedate)= 2011
group by 1, 2
order by 1, 2;

# 7. LTV계산
-- 1. 연도별 구매자수, 매출액
select year(invoicedate) as YY,
	count(distinct customerid) as pu,
    sum(quantity* unitprice) as rev
from challenge.final
group by 1;

-- 2. Retention Rate
select count(distinct b.customerid)/ count(distinct a.customerid) as retention_rate
from
(select invoicedate,
	customerid
from challenge.final) as a
	left join
		(select invoicedate, customerid
			from challenge.final) as b
		on a.customerid= b.customerid
			and year(a.invoicedate)= year(b.invoicedate)- 1;
-- 0.1910

-- 3. 2012년 구매자 수 예측
-- 2011년 구매자 수 * 재구매율
-- 765* 0.1910= 146

-- 4. 2012년 매출액 예측
-- 2011년 ARPPU * 3번결과
-- 690.9* 146= 100871.4
create temporary table pu_rev
select year(invoicedate) as YY,
	count(distinct customerid) as pu,
    sum(quantity* unitprice) as rev
from challenge.final
group by 1;

insert into pu_rev
	value (2012, 146, 100871.4);

select *
from pu_rev;