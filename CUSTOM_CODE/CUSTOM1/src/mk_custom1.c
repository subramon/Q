#include "q_incs.h"
#include <jansson.h>
#include "mk_custom1.h"

int
mk_custom1(
    char * X,
    uint32_t nX,
    uint32_t width,
    custom1_t *Y
    )
{
  int status = 0;
  json_t *root = NULL;
  json_error_t error;

  for ( uint32_t i = 0; i < nX; i++ ) {
    root = json_loads(X+(i*width), 0, &error);
    if ( root == NULL ) { 
      fprintf(stderr, "%u: Invalid JSON %s \n", i, X+(i*width));
      go_BYE(-1); 
    } 
    json_t *x = NULL;
    uint64_t bmask = 0;
#include "gen_mk_custom1.c"
    Y[i].bmask = bmask;
  }

BYE:
  if ( root != NULL ) { json_decref(root); }
  return status;
}
