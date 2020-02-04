#define _XOPEN_SOURCE
#include "q_incs.h"
#include <time.h>
#include <inttypes.h>
#include "SC_to_TM.h"
#include "TM_to_SC.h"
#include "TM_to_I8.h"
int
main(void)
{
#define N 3
  int status = 0;
  struct tm outv[N];
  char *inv = NULL;
  const char *str = "2001-11-12 18:31:01";
  const char *format = "%Y-%m-%d %H:%M:%S";
  char buf[1024];
  char *chk_inv = NULL;
  int64_t *secs = NULL;

  int width = strlen(str) + 1;

  inv = malloc(width * N);
  return_if_malloc_failed(inv);
  for ( int i = 0; i < N; i++ ) { 
    strcpy(inv+(i*width), str);
  }

  int out_width = 32;
  chk_inv = malloc(out_width * N);
  return_if_malloc_failed(chk_inv);
  memset(chk_inv, '\0', out_width*N);

  secs = malloc(sizeof(int64_t) * N);
  return_if_malloc_failed(secs);
  //-------------------------
  status = SC_to_TM(inv, width, N, format, outv); cBYE(status);
  for ( int i = 0; i < N; i++ ) { 
    strftime(buf, sizeof(buf), "%d %b %Y %H:%M", outv+i);
    if ( strcmp(buf, "12 Nov 2001 18:31") != 0 ) { go_BYE(-1); }
  }
  //-------------------------
  status = TM_to_SC(outv, N, format, chk_inv, out_width); cBYE(status);
  for ( int i = 0; i < N; i++ ) { 
    // fprintf(stderr, "%d: %s \n", i, chk_inv+(i*out_width));
    if ( strcmp(inv+(i*width), chk_inv+(i*out_width)) != 0 ) { go_BYE(-1); }

  }
  status = TM_to_I8(outv, N, secs); cBYE(status);
  for ( int i = 0; i < N; i++ ) { 
    // fprintf(stderr, "%d: %" PRIu64 "\n", i, secs[i]);
    if ( secs[i] != 1005589861 ) { go_BYE(-1); }
  }
BYE:
  free_if_non_null(inv); 
  free_if_non_null(chk_inv); 
  free_if_non_null(secs); 
  return status;
}
