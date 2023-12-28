// From Doug Lemire
// https://lemire.me/blog/2022/11/10/measuring-the-memory-usage-of-your-c-program/
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <sys/resource.h>
#include <unistd.h>
#include "q_macros.h"
#include "mem_info.h"
// TODO Why is include causing problems? #include "nadeau.h"
/*
 *  * Author:  David Robert Nadeau
 *   * Site:    http://NadeauSoftware.com/
 *    * License: Creative Commons Attribution 3.0 Unported License
 *     *          http://creativecommons.org/licenses/by/3.0/deed.en_US
 *      */

/**
 *  * Returns the peak (maximum so far) resident set size (physical
 *   * memory use) measured in bytes, or zero if the value cannot be
 *    * determined on this OS.
 *     */
static size_t 
getPeakRSS(void) 
{
  struct rusage rusage;
  getrusage(RUSAGE_SELF, &rusage);
  return (size_t)(rusage.ru_maxrss * 1024L);
}

/**
 *  * Returns the current resident set size (physical memory use) measured
 *   * in bytes, or zero if the value cannot be determined on this OS.
 *    */
static size_t 
getCurrentRSS(void) 
{
  long rss = 0L;
  FILE *fp = NULL;
  if ((fp = fopen("/proc/self/statm", "r")) == NULL)
    return (size_t)0L; /* Can't open? */
  if (fscanf(fp, "%*s%ld", &rss) != 1) {
    fclose(fp);
    return (size_t)0L; /* Can't read? */
  }
  fclose(fp);
  return (size_t)rss * (size_t)sysconf(_SC_PAGESIZE);
}

//START_FUNC_DECL
int 
mem_info(
    size_t *ptr_pagesize, 
    int64_t *ptr_bytes, 
    size_t *ptr_pages
    )
//STOP_FUNC_DECL
{
  int status= 0;
  *ptr_pagesize = sysconf(_SC_PAGESIZE);
  *ptr_bytes = getCurrentRSS();
  if ( (*ptr_bytes % *ptr_pagesize) != 0 ) { go_BYE(-1); }
  *ptr_pages = *ptr_bytes / *ptr_pagesize;
BYE:
  return status;
}
//--------------
// IMPORTANT: Note difference when memset is invoked 
#undef UNIT_TEST
#ifdef UNIT_TEST
static void 
lpr(
    size_t pagesize, 
    int64_t bytes, 
    size_t pages
   )
{
  printf("pagesize = %u \n", pagesize);
  printf("bytes    = %u \n", bytes);
  printf("pages    = %u \n", pages);
}
int 
main() 
{
  int status = 0;
  size_t pagesize; int64_t bytes; size_t pages; 
  int *X,*Y,*Z;
  status = mem_info(&pagesize, &bytes, &pages);
  lpr(pagesize, bytes, pages);

  X = malloc(1000000);
  // memset(X, 0, 1000000);
  status = mem_info(&pagesize, &bytes, &pages);
  lpr(pagesize, bytes, pages);
  
  Y = malloc(10000000);
  // memset(Y, 0, 10000000);
  status = mem_info(&pagesize, &bytes, &pages);
  lpr(pagesize, bytes, pages);
 
  Z = malloc(100000000);
  // memset(Z, 0, 100000000);
  status = mem_info(&pagesize, &bytes, &pages);
  lpr(pagesize, bytes, pages);

  free(X); free(Y); free(Z);
BYE:
  return status;
}
#endif
