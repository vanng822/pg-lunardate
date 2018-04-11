#include "postgres.h"
#include "utils/date.h"
#include "utils/datetime.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include "amlich.c"

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(lunardate_in);
Datum
lunardate_in(PG_FUNCTION_ARGS) {
    char *str = PG_GETARG_CSTRING(0);
    int year, month, day, result;
    solar_date *d;
    if (sscanf(str, "%u-%u-%u", &year, &month, &day) != 3) {
        ereport(ERROR,
          (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
          errmsg("invalid input syntax for lunardate: \"%s\"", str)));
    }
    d = lunar2solar(day, month, year, 0, TIMEZONE);
    if (!IS_VALID_JULIAN(d->year, d->month, d->day)) {
        ereport(ERROR,
          (errcode(ERRCODE_DATETIME_VALUE_OUT_OF_RANGE),
          errmsg("date out of range: \"%s\"", str)));
    }
    result = jd_from_date(d->day, d->month, d->year);
    //elog(INFO, "lunardate_in %d-%d-%d (jd %d)", d->year, d->month, d->day, result);
    pfree(d);
    PG_RETURN_INT32(result);
}

PG_FUNCTION_INFO_V1(lunardate_out);
Datum
lunardate_out(PG_FUNCTION_ARGS) {
    int jd = PG_GETARG_INT32(0);
    char *result;
    solar_date *sdate;
    lunar_date *ldate;
    //elog(INFO, "lunardate_out %d", jd);
    sdate = jd_to_date(jd);
    ldate = solar2lunar(sdate->day, sdate->month, sdate->year, TIMEZONE);
    pfree(sdate);
    int size = 10 + VARHDRSZ;
    result = (char *) palloc(size);
    snprintf(result, size, "%04u-%02u-%02u", ldate->year, ldate->month, ldate->day);
    pfree(ldate);
    PG_RETURN_CSTRING(result);
}

PG_FUNCTION_INFO_V1(lunardate2date);
Datum
lunardate2date(PG_FUNCTION_ARGS) {
    int jd = PG_GETARG_INT32(0);
    DateADT date;
    solar_date *sdate;
    sdate = jd_to_date(jd);
    date = date2j(sdate->year, sdate->month, sdate->day) - POSTGRES_EPOCH_JDATE;
    pfree(sdate);
    PG_RETURN_DATEADT(date);
}

PG_FUNCTION_INFO_V1(date2lunardate);
Datum
date2lunardate(PG_FUNCTION_ARGS) {
    DateADT	date = PG_GETARG_DATEADT(0);
    struct pg_tm tt,
			   *tm = &tt;
    if (DATE_NOT_FINITE(date)) {
      ereport(ERROR,
        (errcode(ERRCODE_DATETIME_VALUE_OUT_OF_RANGE),
        errmsg("Can not handle not finite date")));
    }
    j2date(date + POSTGRES_EPOCH_JDATE, &(tm->tm_year), &(tm->tm_mon), &(tm->tm_mday));
    int result = jd_from_date(tm->tm_mday, tm->tm_mon, tm->tm_year);
    PG_RETURN_INT32(result);
}
