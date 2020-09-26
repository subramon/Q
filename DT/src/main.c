#include "incs.h"
#include "mk_data.h"
#include "read_data.h"
#include "pr_data.h"
#include "preproc.h"
#include "split.h"

metrics_t *g_M;  // [g_M_m][g_M_bufsz] 
uint32_t g_M_m;
uint32_t g_M_bufsz;

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
  // One time allocation for later use 
  g_M = NULL;
  g_M_m = m;
  g_M_bufsz = BUFSZ;
  g_M = malloc(g_M_m * sizeof(metrics_t));
  return_if_malloc_failed(g_M);
  memset(g_M, 0,  (g_M_m * sizeof(metrics_t)));
  for ( uint32_t j = 0; j < g_M_m; j++ ) { 
    g_M[j].yval   = malloc(g_M_bufsz * sizeof(uint32_t));
    g_M[j].yidx   = malloc(g_M_bufsz * sizeof(uint32_t));
    g_M[j].nT     = malloc(g_M_bufsz * sizeof(uint32_t));
    g_M[j].nH     = malloc(g_M_bufsz * sizeof(uint32_t));
    g_M[j].metric = malloc(g_M_bufsz * sizeof(double));
  }
  //-----------------------------------------------
  status = read_data(&X, m, n, &g); cBYE(status); 
  status = mk_data(&X, m, n, &g); cBYE(status);
#ifdef VERBOSE
  status = pr_data_f(X, m, g, lb, ub); cBYE(status);
#endif
  printf("Generated data \n");
  status = preproc(X, m, n, g, &nT, &nH, &Y, &to, &tmpY); cBYE(status);
  printf("Pre-processed data \n");
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
