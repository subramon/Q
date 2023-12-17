#include "q_incs.h"
#include "qtypes.h"
#include "cat_to_buf.h"
#include "pr_custom1.h"

#define  mcr_pr_comma() { \
  if ( first ) {  \
    first = false; \
  } \
  else {  \
    status = cat_to_buf(&buf, &bufsz, &buflen, ", ", 2);  \
  } \
}
int
pr_custom1(
    custom1_t *x,
    char **ptr_buf
    )
{
  int status = 0;
  char *buf = NULL; uint32_t bufsz = 0, buflen = 0; 
  bool first = true; 
  char tmp[64];
  bufsz = 1024; 
  buf = malloc(bufsz);
  return_if_malloc_failed(buf);
  memset(buf, 0, bufsz);
  status = cat_to_buf(&buf, &bufsz, &buflen, "{ ", 2);
#include "gen_pr_custom1.c"
  /*
  if ( (x->bmask & ((uint64_t)1 << 0)) != 0 ) {
    sprintf(tmp, "\"intercept\" : %f ", x->intercept);
  }
  mcr_pr_comma();
  */
  status = cat_to_buf(&buf, &bufsz, &buflen, "} ", 2);
  *ptr_buf = buf;
BYE:
  return status; 
}
