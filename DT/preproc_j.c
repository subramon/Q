#include <stdio.h>
#include <stdlib.h>

int 
preproc_j(
    float *Xj, /* [m][n] */
    int n,
    int *g,
    uint32_t **ptr_Yj
   )
{
  int status = 0;
  uint32_t *Yj = NULL;
  uint32_t *idx = NULL;
  // allocate Y and idx 
  Yj  = malloc(n * sizeof(uint32_t));
  idx = malloc(n * sizeof(uint32_t));
  for ( int i = 0; i < n; i++ ) { 
    idx[i] = i;
  }
  // sort X, idx, g
  // create Y 
  float xval = Xj[0];
  uint32_t yval = 1;
  Yj[0] = yval | (g[0] << 31); 
  for ( int i = 1; i < n; i++ ) { 
    if ( Xj[i] != xval ) {
      xval = Xj[i];
      yval++;
    }
    Yj[0] = yval | (g[0] << 31); 
  }
  *ptr_Yj = Yj;
BYE:
  free_if_non_null(idx);
  return status;
}
