#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include "amlich.c"

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(lunardate_in);
Datum
lunardate_in(PG_FUNCTION_ARGS)
{
    char *str = PG_GETARG_CSTRING(0);
    int year, month, day, result;
    solar_date *d;
    if (sscanf(str, "%d-%d-%d", &year, &month, &day) != 3) {
        ereport(ERROR,
                (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
                 errmsg("invalid input syntax for lunardate: \"%s\"",
                        str)));
    }
    d = lunar2solar(day, month, year, 0, TIMEZONE);
    result = jd_from_date(d->day, d->month, d->year);
    elog(INFO, "scan %d-%d-%d (jd %d)", d->year, d->month, d->day, result);
    PG_RETURN_INT32(result);
}

PG_FUNCTION_INFO_V1(lunardate_out);
Datum
lunardate_out(PG_FUNCTION_ARGS)
{
    int jd = PG_GETARG_INT32(0);
    char *result;
    solar_date *sdate;
    lunar_date *ldate;
    elog(INFO, "from mem %d", jd);
    sdate = jd_to_date(jd);
    ldate = solar2lunar(sdate->day, sdate->month, sdate->year, TIMEZONE);
    int size = 10 + VARHDRSZ;
    result = (char *) palloc(size);
    snprintf(result, size, "%d-%d-%d", ldate->year, ldate->month, ldate->day);
    PG_RETURN_CSTRING(result);
}

PG_FUNCTION_INFO_V1(lunar2solardate);
Datum
lunar2solardate(PG_FUNCTION_ARGS)
{
    int jd = PG_GETARG_INT32(0);
    char *result;
    solar_date *sdate;
    sdate = jd_to_date(jd);
    int size = 10 + VARHDRSZ;
    result = (char *) palloc(size);
    snprintf(result, size, "%d-%d-%d", sdate->year, sdate->month, sdate->day);
    PG_RETURN_CSTRING(result);
}
