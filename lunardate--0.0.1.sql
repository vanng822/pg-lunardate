\echo Use "CREATE EXTENSION lunardate" to load this file. \quit

CREATE FUNCTION lunardate_in(cstring)
RETURNS lunardate
AS '$libdir/lunardate'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION lunardate_out(lunardate)
RETURNS cstring
AS '$libdir/lunardate'
LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE lunardate (
  INPUT          = lunardate_in,
  OUTPUT         = lunardate_out,
  internallength = 16,
  alignment      = integer
);

CREATE FUNCTION lunardate_eq(lunardate, lunardate)
RETURNS boolean AS '$libdir/lunardate'
LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR = (
  LEFTARG = lunardate,
  RIGHTARG = lunardate,
  PROCEDURE = lunardate_eq,
  COMMUTATOR = '=',
  NEGATOR = '<>',
  RESTRICT = eqsel,
  JOIN = eqjoinsel,
  HASHES, MERGES
);
