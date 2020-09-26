#include "incs.h"
#include "mk_data.h"
#include "read_data.h"
#include "pr_data.h"
#include "preproc.h"
#include "split.h"

int
main(
    void
    )
{
  int status = 0;
  uint32_t n = NUM_INSTANCES;
  uint8_t  m = NUM_FEATURES;
  float **X = NULL;  // [m][n]
  uint64_t **Y  = NULL; // [m][n]
  uint64_t **tmpY  = NULL; // [n]
  uint32_t **to = NULL; // [m][n]
  uint8_t *g = NULL; // [n]
  uint32_t nT = 0; uint32_t nH = 0;
  uint32_t lb = 0; uint32_t ub = n;
  //-----------------------------------------------
  status = read_data(&X, m, n, &g); cBYE(status); 
  status = mk_data(&X, m, n, &g); cBYE(status);
#ifdef VERBOSE
  status = pr_data_f(X, m, g, lb, ub); cBYE(status);
#endif
  status = preproc(X, m, n, g, &nT, &nH, &Y, &to, &tmpY); cBYE(status);
  status = split(to, g, lb, ub, nT, nH, n, m, Y, tmpY); cBYE(status);
BYE:
  for ( uint32_t j = 0; j < m; j++ ) { 
    if ( X != NULL ) { free_if_non_null(X[j]); }
    if ( Y != NULL ) { free_if_non_null(Y[j]); }
    if ( tmpY != NULL ) { free_if_non_null(tmpY[j]); }
    if ( to != NULL ) { free_if_non_null(to[j]); }
  }
  free_if_non_null(X);
  free_if_non_null(Y);
  free_if_non_null(tmpY);
  free_if_non_null(to);
  free_if_non_null(g);
  return status;
}
