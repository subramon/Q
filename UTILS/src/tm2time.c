#include "q_incs.h"
#include "qtypes.h"
#include "tm2time.h"
//START_FUNC_DECL
time_t
tm2time(
    const struct tm *src
    )
//STOP_FUNC_DECL
{
  time_t t1 = timegm((struct tm *)src);
  time_t t2 = src->tm_gmtoff;
  return t1 - t2; 
}
/*
 * http://kbyanc.blogspot.com/2007/06/c-converting-struct-tm-times-with.html
 *
 * C: Converting struct tm times with timezone to time_t
Both the BSD and GNU standard C library have extended the struct tm to include a tm_gmtoff member that holds the offset from UTC of the time represented by the structure. Which might lead you to believe that mktime(3) would honor the time offset indicated by tm_gmtoff when converting to a time_t representation.

Nope.

mktime(3) always assumes the "current timezone" defined by the executing environment. Since ISO C and POSIX define the semantics for mktime(3) but neither defines a tm_gmtoff member for the tm structure, not surprisingly mktime(3) does not honor it.

So, lets say you have a struct tm, complete with correctly-populated tm_gmtoff field: how do you convert it to a time_t representation?

Many modern C libraries (including glibc and FreeBSD's libc) include a timegm(3) function. No, this function doesn't honor tm_gmtoff either. Instead, gmtime(3) converts the struct tm to a time_t just like mktime(3), but ignores the timezone of the executing environment and always assumes GMT as the timezone.

However, if your libc implements both tm_gmtoff and timegm(3) you are in luck. You just need to use timegm(3) to get the time_t representing the time in GMT and then subtract the offset stored in tm_gmtoff. The tricky part is that calling timegm(3) will modify the struct tm, clearing the tm_gmtoff field to zero (at least it does on the FreeBSD 4.10 machine I'm testing with). Combined with C's lack of guaranteed left-to-right evaluation, you need to save the tm_gmtoff so it doesn't get clobbered before you can use it. Something like:

time_t
tm2time(const struct tm *src)
{
       struct tm tmp;

       tmp = *src;
       return timegm(&tmp) - src->tm_gmtoff;
}

*/
