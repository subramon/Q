#define _XOPEN_SOURCE
#include "q_incs.h"
#include <time.h>
#include "SC_to_TM.h"
int
main(void)
{
#define N 3
  int status = 0;
  tm outv[N];
  char *inv = NULL;
  const char *str = "2001-11-12 18:31:01";
  const char *format = "%Y-%m-%d %H:%M:%S";
  char buf[1024];

  int len = strlen(str) + 1;
  inv = malloc(len * N);
  return_if_malloc_failed(inv);
  for ( int i = 0; i < N; i++ ) { 
    strcpy(inv+(i*len), str);
  }
  status = SC_to_TM(inv, len, N, format, outv); cBYE(status);
  for ( int i = 0; i < N; i++ ) { 
    strftime(buf, sizeof(buf), "%d %b %Y %H:%M", outv+i);
    if ( strcmp(buf, "12 Nov 2001 18:31") != 0 ) { go_BYE(-1); }
  }
BYE:
  free_if_non_null(inv); 
  return status;
}
