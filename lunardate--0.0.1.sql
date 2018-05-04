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
  LIKE      = integer
);

CREATE FUNCTION lunardate2date(lunardate)
RETURNS date
AS '$libdir/lunardate'
LANGUAGE C IMMUTABLE STRICT;

CREATE CAST (lunardate AS date)
WITH FUNCTION lunardate2date(lunardate);

CREATE FUNCTION date2lunardate(date)
RETURNS lunardate
AS '$libdir/lunardate'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION lunardate_plus_interval(lunardate, interval)
RETURNS lunardate
AS '$libdir/lunardate'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION lunardate_minus_interval(lunardate, interval)
RETURNS lunardate
AS '$libdir/lunardate'
LANGUAGE C IMMUTABLE STRICT;

CREATE CAST (date AS lunardate)
WITH FUNCTION date2lunardate(date);

CREATE FUNCTION lunardate_eq(lunardate, lunardate)
RETURNS boolean LANGUAGE internal IMMUTABLE AS 'int4eq';

CREATE FUNCTION lunardate_ne(lunardate, lunardate)
RETURNS boolean LANGUAGE internal IMMUTABLE AS 'int4ne';

CREATE FUNCTION lunardate_lt(lunardate, lunardate)
RETURNS boolean LANGUAGE internal IMMUTABLE AS 'int4lt';

CREATE FUNCTION lunardate_le(lunardate, lunardate)
RETURNS boolean LANGUAGE internal IMMUTABLE AS 'int4le';

CREATE FUNCTION lunardate_gt(lunardate, lunardate)
RETURNS boolean LANGUAGE internal IMMUTABLE AS 'int4gt';

CREATE FUNCTION lunardate_ge(lunardate, lunardate)
RETURNS boolean LANGUAGE internal IMMUTABLE AS 'int4ge';

CREATE FUNCTION lunardate_cmp(lunardate, lunardate)
RETURNS integer LANGUAGE internal IMMUTABLE AS 'btint4cmp';

CREATE FUNCTION hash_lunardate(lunardate)
RETURNS integer LANGUAGE internal IMMUTABLE AS 'hashint4';


CREATE OPERATOR + (
  LEFTARG = lunardate,
  RIGHTARG = interval,
  PROCEDURE = lunardate_plus_interval
);

CREATE OPERATOR - (
  LEFTARG = lunardate,
  RIGHTARG = interval,
  PROCEDURE = lunardate_minus_interval
);

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

CREATE OPERATOR <> (
  LEFTARG = lunardate,
  RIGHTARG = lunardate,
  PROCEDURE = lunardate_ne,
  COMMUTATOR = '<>',
  NEGATOR = '=',
  RESTRICT = neqsel,
  JOIN = neqjoinsel
);

CREATE OPERATOR < (
  LEFTARG = lunardate,
  RIGHTARG = lunardate,
  PROCEDURE = lunardate_lt,
  COMMUTATOR = > ,
  NEGATOR = >= ,
  RESTRICT = scalarltsel,
  JOIN = scalarltjoinsel
);

CREATE OPERATOR <= (
  LEFTARG = lunardate,
  RIGHTARG = lunardate,
  PROCEDURE = lunardate_le,
  COMMUTATOR = >= ,
  NEGATOR = > ,
  RESTRICT = scalarltsel,
  JOIN = scalarltjoinsel
);

CREATE OPERATOR > (
  LEFTARG = lunardate,
  RIGHTARG = lunardate,
  PROCEDURE = lunardate_gt,
  COMMUTATOR = < ,
  NEGATOR = <= ,
  RESTRICT = scalargtsel,
  JOIN = scalargtjoinsel
);

CREATE OPERATOR >= (
  LEFTARG = lunardate,
  RIGHTARG = lunardate,
  PROCEDURE = lunardate_ge,
  COMMUTATOR = <= ,
  NEGATOR = < ,
  RESTRICT = scalargtsel,
  JOIN = scalargtjoinsel
);

CREATE OPERATOR CLASS btree_lunardate_ops
DEFAULT FOR TYPE lunardate USING btree
AS
        OPERATOR        1       <  ,
        OPERATOR        2       <= ,
        OPERATOR        3       =  ,
        OPERATOR        4       >= ,
        OPERATOR        5       >  ,
        FUNCTION        1       lunardate_cmp(lunardate, lunardate);

CREATE OPERATOR CLASS hash_lunardate_ops
    DEFAULT FOR TYPE lunardate USING hash AS
        OPERATOR        1       = ,
        FUNCTION        1       hash_lunardate(lunardate);
