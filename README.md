# pg-lunardate

`pg-lunardate` is a PostgreSQL extension that adds a lunar calendar date type.
It supports conversion between `lunardate` and PostgreSQL's built-in `date`
type, comparisons, B-tree and hash indexes, and interval arithmetic.

> [!WARNING]
> This project was created as a learning exercise and has not been validated
> for production use. Review the implementation and test it against your own
> date and timezone requirements before relying on it.

## Requirements

- PostgreSQL 16
- A C compiler and PostgreSQL server development headers for a native build
- Docker, if using the recommended containerized setup

## Quick start with Docker

Build the image:

```sh
docker build --tag pg-lunardate .
```

Start PostgreSQL:

```sh
docker run --detach \
	--name pg-lunardate-postgres \
	--env POSTGRES_PASSWORD=postgres \
	--publish 5432:5432 \
	pg-lunardate
```

The image installs the extension and runs `sql/init.sql` when the database is
initialized. Connect to it with:

```sh
psql -h localhost -p 5432 -U postgres
```

The password is `postgres` for this example. Remove the container when you are
finished:

```sh
docker rm --force pg-lunardate-postgres
```

## Native installation

Install PostgreSQL's development package, then run:

```sh
make
sudo make install
```

In a database where the extension is installed, enable it with:

```sql
CREATE EXTENSION lunardate;
```

## Usage

Lunar dates use the format `YYYY-MM-DD` for regular months. Leap months use
`YYYY-rMM-DD`, for example `2025-r06-01`:

```sql
CREATE EXTENSION lunardate;

SELECT '2018-11-11'::lunardate;
SELECT '2018-11-11'::lunardate::date;
SELECT '2018-12-17'::date::lunardate;
SELECT '2025-r06-01'::lunardate;
```

The type can be stored in tables and compared or indexed:

```sql
CREATE TABLE lunar_events (
	name text NOT NULL,
	event_date lunardate NOT NULL
);

CREATE INDEX ON lunar_events (event_date);

INSERT INTO lunar_events VALUES ('Example event', '2018-11-11');
SELECT * FROM lunar_events WHERE event_date = '2018-11-11';
```

Supported operations include adding or subtracting an interval and extracting
the lunar year, month, or day:

```sql
SELECT '2018-11-13'::lunardate + interval '20 years';
SELECT '2018-11-13'::lunardate - interval '2 years';
SELECT lunardate_date_part('year', '2018-11-13'::lunardate);
SELECT lunardate_date_part('month', '2018-11-13'::lunardate);
SELECT lunardate_date_part('day', '2018-11-13'::lunardate);
```

## Run the tests

The regression test uses PostgreSQL's PGXS test framework:

```sh
make installcheck
```

The GitHub Actions workflow builds the Docker image, starts PostgreSQL, and
runs the same regression test automatically for pushes and pull requests.

## License

No license has been specified yet.
