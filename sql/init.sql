CREATE EXTENSION IF NOT EXISTS lunardate;
DROP TABLE IF EXISTS lunartest;

CREATE TABLE lunartest(
  id serial PRIMARY KEY,
  from_date lunardate,
  to_date lunardate
);