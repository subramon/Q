#include "incs.h"
#include "mk_data.h"
#include "pr_data.h"
#include "preproc.h"
#include "split.h"

int
main(
    void
    )
{
  int status = 0;
  float **X = NULL; 
  uint8_t *lr  = NULL; // [n] whether left or right 
  uint32_t **Y  = NULL;
  uint32_t **to = NULL;
  uint32_t **from = NULL;
  uint8_t *g = NULL;
  uint32_t n = NUM_INSTANCES;
  uint8_t  m = NUM_FEATURES;
  status = mk_data(&X, m, n, &g); cBYE(status);
  uint32_t lb = 0; uint32_t ub = n;
  status = pr_data_f(X, m, n, g, lb, ub); cBYE(status);
  lr = malloc(n * sizeof(uint8_t));
  status = preproc(X, m, n, g, &Y, &to, &from); cBYE(status);
  status = split(lr, from, lb, ub, n, m); cBYE(status);
  status = pr_data_i(X, Y, from, to, m, n, lr, g, lb, ub); cBYE(status);
BYE:
  for ( uint32_t j = 0; j < m; j++ ) { 
    free_if_non_null(X[j]);
    free_if_non_null(Y[j]);
    free_if_non_null(to[j]);
    free_if_non_null(from[j]);
  }
  free_if_non_null(X);
  free_if_non_null(Y);
  free_if_non_null(to);
  free_if_non_null(from);
  free_if_non_null(g);
  free_if_non_null(lr);
  return status;
}

