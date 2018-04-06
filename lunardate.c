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
    int year, month, day;
    lunar_date *d;
    //solardate *dd;
    if (sscanf(str, "%d-%d-%d", &year, &month, &day) != 3) {
        ereport(ERROR,
                (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
                 errmsg("invalid input syntax for lunardate: \"%s\"",
                        str)));
    }
    d = (lunar_date *) palloc(sizeof(lunar_date));
    d->year = year;
    d->month = month;
    d->day = day;
    elog(INFO, "scan %d-%d-%d", d->year, d->month, d->day);
    PG_RETURN_POINTER(d);
}

PG_FUNCTION_INFO_V1(lunardate_out);
Datum
lunardate_out(PG_FUNCTION_ARGS)
{
    lunar_date *d = (lunar_date *) PG_GETARG_POINTER(0);
    elog(INFO, "from mem %d-%d-%d", d->year, d->month, d->day);
    char *result;
    int size = 10 + VARHDRSZ;
    result = (char *) palloc(size);
    snprintf(result, size, "%d-%d-%d", d->year, d->month, d->day);
    PG_RETURN_CSTRING(result);
}

PG_FUNCTION_INFO_V1(lunardate_eq);
Datum
lunardate_eq(PG_FUNCTION_ARGS)
{
    lunar_date *dleft = (lunar_date *) PG_GETARG_POINTER(0);
    lunar_date *dright = (lunar_date *) PG_GETARG_POINTER(1);
    elog(INFO, "compare %d-%d-%d", dleft->year, dleft->month, dleft->day);
    elog(INFO, "compare %d-%d-%d", dright->year, dright->month, dright->day);
    bool *result;
    result = (lunar_date_compare(dleft, dright) == 0);
    PG_RETURN_CSTRING(result);
}
