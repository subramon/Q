#include "incs.h"
#include "preproc_j.h"
#include "preproc.h"

int 
preproc(
    float **X, /* [m][n] */
    uint32_t m,
    uint32_t n,
    uint8_t *g,
    uint64_t ***ptr_Y, 
    uint32_t ***ptr_to,
    uint64_t **ptr_tmp_Yj
   )
{
  int status = 0;
  uint64_t **Y = NULL; // [m][n]
  uint32_t **to = NULL; // [m][n]
  uint64_t *tmp_Yj = NULL; // [n]

  tmp_Yj = malloc(n * sizeof(uint64_t));
  return_if_malloc_failed(tmp_Yj);
  Y      = malloc(m * sizeof(uint64_t *));
  return_if_malloc_failed(Y);
  to     = malloc(m * sizeof(uint32_t *));
  return_if_malloc_failed(to);

  for ( uint32_t j = 0; j < m; j++ ) { 
    status = preproc_j(X[j], n, g,  &(Y[j]), &(to[j]));
    cBYE(status);
  }
  *ptr_Y      = Y;
  *ptr_tmp_Yj = tmp_Yj;
  *ptr_to     = to;
BYE:
  if ( status < 0 ) { 
    if ( Y != NULL ) { 
      for ( uint32_t j = 0; j < m; j++ ) { free_if_non_null(Y[j]); }
    }
    if ( to != NULL ) { 
      for ( uint32_t j = 0; j < m; j++ ) { free_if_non_null(to[j]); }
    }
    free_if_non_null(Y); 
    free_if_non_null(to); 
    free_if_non_null(tmp_Yj); 
  }
  return status;
}
