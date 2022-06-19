use wallmart;

select count(*)
from wallmart.data;

select *
from data;


# date 컬럼 변경
-- 문자열 -> 날짜
update data
set date= str_to_date(date, '%d-%m-%Y');

select *
from data;

# 월별 매출
select substr(date, 1, 7) as YM,
	sum(weekly_sales) as rev_monthly
from data
group by 1
order by 1;

# 매점별 월별 매출
select store,
	substr(date, 1, 7) as YM,
    sum(weekly_sales) as rev_monthly
from data
group by 1, 2
order by 1, 2;

# 월별 공휴일에 따른 매출
-- 1 : Holiday // 0 : non-Holiday
select substr(date, 1, 7) as YM,
	holiday_flag,
	sum(weekly_sales) as rev_monthly
from data
group by 1, 2
order by 1, 2;
-- 매점별 월별 공휴일에 따른 매출
select store,
	substr(date, 1, 7) as YM,
	holiday_flag,
	sum(weekly_sales) as rev_monthly
from data
group by 1, 2, 3
order by 1, 2;

# 매점별 기온에 따른 평균 매출
select min(temperature), max(temperature)
from data;
-- 화씨 -2도= 섭씨 -19도 // 화씨 100도= 섭씨 약 38도
-- 10도 단위로 구간 나누기로 결정
select store,
		case when temperature between -20 and -10 then 'extremely_cold'
			when temperature between -9 and 0 then 'very_cold'
            when temperature between 1 and 10 then 'little_cold'
            when temperature between 11 and 20 then 'little_hot'
            when temperature between 21 and 30 then 'hot'
            else 'extremely_hot'
		end as weather,
        avg(weekly_sales) as rev
from data
group by 1, 2
order by 1;
-- 기온별 매출
select case when temperature between -20 and -10 then 'extremely_cold'
			when temperature between -9 and 0 then 'very_cold'
            when temperature between 1 and 10 then 'little_cold'
            when temperature between 11 and 20 then 'little_hot'
            when temperature between 21 and 30 then 'hot'
            else 'extremely_hot'
		end as weather,
        avg(weekly_sales) as rev
from data
group by 1;

# CPI (소비자 물가지수)에 따른 평균 매출
-- 최소 126.06, 쵀대 227.23
-- 10개 구간으로 나누기로 결정
select min(cpi), max(cpi), avg(cpi)
from data;
-- 월별 CPI, 평균 매출
select substr(date, 1, 7) as YM,
	avg(cpi) as 'CPI',
    avg(weekly_sales) as rev
from data
group by 1
order by 1;

select case when cpi between 126 and 135 then 'low_1'
			when cpi between 136 and 145 then 'low_2'
            when cpi between 146 and 155 then 'low_3'
            when cpi between 156 and 165 then 'mid_1'
            when cpi between 166 and 175 then 'mid_2'
            when cpi between 176 and 185 then 'mid_3'
            when cpi between 186 and 195 then 'high_1'
            when cpi between 196 and 205 then 'high_2'
            when cpi between 206 and 216 then 'high_3'
            else 'high_4'
		end as cpi_bins,
        avg(weekly_sales) as rev
from data
group by 1;
-- CPI에 따른 매점별 평균 매출
select store,
		case when cpi between 126 and 135 then 'low_1'
			when cpi between 136 and 145 then 'low_2'
			when cpi between 146 and 155 then 'low_3'
            when cpi between 156 and 165 then 'mid_1'
            when cpi between 166 and 175 then 'mid_2'
            when cpi between 176 and 185 then 'mid_3'
            when cpi between 186 and 195 then 'high_1'
            when cpi between 196 and 205 then 'high_2'
            when cpi between 206 and 216 then 'high_3'
            else 'high_4'
		end as cpi_bins,
        avg(weekly_sales) as rev
from data
group by 1, 2
order by 1;

select *
from data;