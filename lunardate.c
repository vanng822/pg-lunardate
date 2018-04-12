#include "postgres.h"
#include "utils/date.h"
#include "utils/datetime.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include "lib/amlich.c"

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(lunardate_in);
Datum
lunardate_in(PG_FUNCTION_ARGS) {
    char *str = PG_GETARG_CSTRING(0);
    int year, month, day, result;
    solar_date *d;
    lunar_date *l;
    if (sscanf(str, "%u-%u-%u", &year, &month, &day) != 3) {
        ereport(ERROR,
          (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
          errmsg("invalid input syntax for lunardate: \"%s\"", str)));
    }
    // lunar2solar just accumulate total number of julian days
    // It first calculate for the year and the month
    // and then added the day to it. To be able to detect if a lunardate
    // is not correct we convert to solar date and back
    // if they are the same then the lunar date is correct
    // incorrect lunar date example:
    //  lunar 1991-04-51 -> solar 1991-07-03 -> lunar 1991-05-22
    // correct lunar example:
    // lunar 1991-04-22 -> solar 1991-06-04 -> lunar 1991-04-22
    // TODO: better way to do this check
    d = lunar2solar(day, month, year, 0, TIMEZONE);
    l = solar2lunar(d->day, d->month, d->year, TIMEZONE);
    if (l->year != year || l->month != month || l->day != day) {
      pfree(d);
      pfree(l);
      ereport(ERROR,
        (errcode(ERRCODE_DATETIME_VALUE_OUT_OF_RANGE),
        errmsg("date out of range: \"%s\"", str)));
    }
    pfree(l);
    if (!IS_VALID_JULIAN(d->year, d->month, d->day)) {
        pfree(d);
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
