#include "incs.h"
#include "check.h"
#include "preproc_j.h"
#include "preproc.h"

extern config_t g_C;
int 
preproc(
    float ** restrict X, /* [m][n] */
    uint32_t m,
    uint32_t n,
    uint8_t * restrict g,
    uint32_t *ptr_nT, // encoded as 0
    uint32_t *ptr_nH, // encoded as 1
    uint64_t ***ptr_Y, 
    uint32_t ***ptr_to,
    uint64_t ***ptr_tmpY
   )
{
  int status = 0;
  uint64_t **Y = NULL; // [m][n]
  uint32_t **to = NULL; // [m][n]
  uint64_t **tmpY = NULL; // [n]

  Y      = malloc(m * sizeof(uint64_t *));
  return_if_malloc_failed(Y);
  to     = malloc(m * sizeof(uint32_t *));
  return_if_malloc_failed(to);

  //  may want to do this sequentiall to reduce amount of 
  //  memory allocateed in the process of creating Y
  // TODO: Think about this
  // #pragma omp parallel for
  // pre-process features one at a time 
  for ( uint32_t j = 0; j < m; j++ ) { 
    status = preproc_j(X[j], n, g,  &(Y[j]), &(to[j]));  cBYE(status);
  }
  cBYE(status); 
  //-----------------------------------------
  // allocate a buffer (same size as Y) for intermediate storage
  tmpY   = malloc(m * sizeof(uint64_t *));
  return_if_malloc_failed(tmpY);
  for ( uint32_t j = 0; j < m; j++ ) { 
    tmpY[j] = malloc(n * sizeof(uint64_t));
    return_if_malloc_failed(tmpY[j]);
  }
  // compute the number of heads and tails in the training seet
  uint32_t nH = 0;
#pragma omp simd reduction(+:nH)
  for ( uint32_t i = 0; i < n; i++ ) { 
    nH += g[i];
  }
  uint32_t nT = n - nH;
  if ( g_C.is_debug ) { 
    uint32_t chk_nT = 0;
    uint32_t chk_nH = 0;
    for ( uint32_t i = 0; i < n; i++ ) { 
      if ( g[i] == 0 ) { nT++; } else { nH++; }
    }
    if ( chk_nT != nT ) { go_BYE(-1); }
    if ( chk_nH != nH ) { go_BYE(-1); }
  }
  //---------------------------------
  if ( g_C.is_debug ) { 
    status = check(to, g, 0, n, nT, nH, n, m, Y); cBYE(status);
  }
  //---------------------------------
  *ptr_Y    = Y;
  *ptr_tmpY = tmpY;
  *ptr_to   = to;
  *ptr_nT   = nT;
  *ptr_nH   = nH;
BYE:
  if ( status < 0 ) { 
    if ( Y != NULL ) { 
      for ( uint32_t j = 0; j < m; j++ ) { free_if_non_null(Y[j]); }
    }
    if ( tmpY != NULL ) { 
      for ( uint32_t j = 0; j < m; j++ ) { free_if_non_null(tmpY[j]); }
    }
    if ( to != NULL ) { 
      for ( uint32_t j = 0; j < m; j++ ) { free_if_non_null(to[j]); }
    }
    free_if_non_null(Y); 
    free_if_non_null(to); 
    free_if_non_null(tmpY); 
  }
  return status;
}
