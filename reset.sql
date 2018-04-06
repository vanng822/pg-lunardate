DROP TABLE lunartest;
DROP EXTENSION lunardate;
CREATE EXTENSION lunardate;
CREATE TABLE lunartest(
  id serial PRIMARY KEY,
  from_date lunardate,
  to_date lunardate
);

insert into lunartest(from_date, to_date) values('2018-10-10', '2018-10-13');
insert into lunartest(from_date, to_date) values('2018-11-11', '2018-11-13');
select * from lunartest;
select * from lunartest where from_date = '2018-11-11';
