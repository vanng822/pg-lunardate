SET client_min_messages TO WARNING;
DROP TABLE IF EXISTS lunartest;
DROP EXTENSION IF EXISTS lunardate;
CREATE EXTENSION lunardate;
CREATE TABLE lunartest(
  id serial PRIMARY KEY,
  from_date lunardate,
  to_date lunardate
);
SET DateStyle=ISO;
insert into lunartest(from_date, to_date) values('2018-10-10', '2019-01-13');
insert into lunartest(from_date, to_date) values('2018-11-11', '2018-12-01');
select * from lunartest;
select id, from_date as lunar_date, from_date::date as solar_date from lunartest;
select * from lunartest where from_date = '2018-11-11';
select '2018-11-11'::lunardate::date;
select '2018-12-17'::date::lunardate;
select '1991-04-51'::lunardate;
select '1991-13-12'::lunardate;
select ('2018-11-13'::lunardate + interval '20 years');
select ('2018-11-13'::lunardate + interval '20 years 1 month');
select ('2018-11-13'::lunardate + interval '20 years 1 day');
select ('2018-11-13'::lunardate + interval '20 years 1 month 1 day');
select ('2018-11-13'::lunardate + interval '20 years 1 month 1 day 1 hour');
select ('2018-11-13'::lunardate + interval '20 years 1 month 1 day 1 minute');
select ('2018-11-13'::lunardate + interval '20 years 1 month 1 day 1 second');
select ('2018-11-13'::lunardate - interval '2 years');
select ('2018-11-13'::lunardate - interval '2 years 1 month');
select ('2018-11-13'::lunardate - interval '2 years 1 day');
select ('2018-11-13'::lunardate - interval '2 years 1 month 1 day');
select ('2018-11-13'::lunardate - interval '2 years 1 month 1 day 1 hour');
select ('2018-11-13'::lunardate - interval '2 years 1 month 1 day 1 minute');
select ('2018-11-13'::lunardate - interval '2 years 1 month 1 day 1 second');
select lunardate_date_part('year', '2018-11-13'::lunardate);
select lunardate_date_part('month', '2018-11-13'::lunardate);
select lunardate_date_part('day', '2018-11-13'::lunardate);
select lunardate_date_part('blabla', '2018-11-13'::lunardate);
select lunardate_date_part('year', from_date) from lunartest order by id asc limit 1;
select lunardate_date_part('month', from_date) from lunartest order by id asc limit 1;
select lunardate_date_part('day', from_date) from lunartest order by id asc limit 1;
