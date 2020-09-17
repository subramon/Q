#include "incs.h"
#include "mk_data.h"
#include "pr_data.h"
#include "preproc.h"

int
main(
    void
    )
{
  int status = 0;
  float **X = NULL; 
  uint32_t **Y  = NULL;
  uint32_t **to = NULL;
  uint8_t *g = NULL;
  uint32_t n = NUM_INSTANCES;
  uint8_t  m = NUM_FEATURES;
  status = mk_data(&X, m, n, &g); cBYE(status);
  uint32_t lb = 0; uint32_t ub = n;
  status = pr_data_f(X, m, n, g, lb, ub); cBYE(status);
  status = preproc(X, m, n, g, &Y, &to); cBYE(status);
  status = pr_data_i(Y, to, m, n, g, lb, ub); cBYE(status);
BYE:
  for ( uint32_t j = 0; j < m; j++ ) { 
    free_if_non_null(X[j]);
    free_if_non_null(Y[j]);
    free_if_non_null(to[j]);
  }
  free_if_non_null(X);
  free_if_non_null(Y);
  free_if_non_null(to);
  free_if_non_null(g);
  return status;
}

