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
  uint64_t **Y  = NULL;
  uint64_t *tmpY  = NULL;
  uint32_t **to = NULL;
  uint8_t *g = NULL;
  uint32_t n = NUM_INSTANCES;
  uint8_t  m = NUM_FEATURES;
  status = mk_data(&X, m, n, &g); cBYE(status);
  uint32_t lb = 0; uint32_t ub = n;
  status = pr_data_f(X, m, n, g, lb, ub); cBYE(status);

  tmpY = malloc(n * sizeof(uint64_t));

  status = preproc(X, m, n, g, &Y, &to); cBYE(status);
  status = pr_data_i(X, Y, to, m, n, g, lb, ub); 
  status = split(to, lb, ub, n, m, Y, tmpY); cBYE(status);
  status = pr_data_i(X, Y, to, m, n, g, lb, ub); 
  cBYE(status);
BYE:
  if ( X != NULL ) { 
    for ( uint32_t j = 0; j < m; j++ ) { 
      free_if_non_null(X[j]);
    }
  }
  if ( Y != NULL ) { 
    for ( uint32_t j = 0; j < m; j++ ) { 
      free_if_non_null(Y[j]);
    }
  }
  if ( to != NULL ) { 
    for ( uint32_t j = 0; j < m; j++ ) { 
      free_if_non_null(to[j]);
    }
  }
  free_if_non_null(X);
  free_if_non_null(Y);
  free_if_non_null(tmpY);
  free_if_non_null(to);
  free_if_non_null(g);
  return status;
}
