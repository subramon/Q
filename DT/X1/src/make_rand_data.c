#include "incs.h"
#include "consts.h"
#include "types.h"
#include "make_rand_data.h"

int
make_rand_data(
    data_t *D
    )
{
  int status = 0;
  memset(D, 0, sizeof(data_t));
  D->nI = 512 * 1024;  // TODO undo hard code 
  D->nK = 54;   // TODO undo hard code 
  float **fval = NULL;
  fval = malloc(D->nK * sizeof(float *));
  return_if_malloc_failed(fval);
  memset(fval, 0,  D->nK * sizeof(float *));
  for ( uint32_t k = 0; k < D->nK; k++ ) {
    fval[k] = malloc(D->nI * sizeof(float));
    return_if_malloc_failed(fval[k]);
    memset(fval[k], 0,  D->nI * sizeof(float));
    for ( uint32_t i = 0; i < D->nI;  i++ ) { 
      fval[k][i] = ( random() % MAX_VAL );
    }
  }
  for ( uint32_t k = 0; k < D->nK; k++ ) {
    for ( uint32_t i = 0; i < D->nI;  i++ ) { 
      if ( fval[k][i] > MAX_VAL ) { // TODO P4 why does >= fail?
        go_BYE(-1);
      }
    }
  }
  D->fval = fval;
BYE:
  return status;
}

int
free_rand_data(
    data_t *D
    )
{
  int status = 0;
  if ( D == NULL ) { return status; } 
  if ( D->fval != NULL ) { 
    for ( uint32_t k = 0; k < D->nK; k++ ) {
      free_if_non_null(D->fval[k]);
    }
    free_if_non_null(D->fval);
  }
  memset(D, 0, sizeof(data_t));
BYE:
  return status;
}
