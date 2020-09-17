#include <stdio.h>
#include <stdlib.h>

int 
preproc(
    float **X, /* [m][n] */
    int n,
    int m,
    int *g,
    uint32_t ***ptr_Y
   )
{
  int status = 0;
  uint32_t **Y = NULL;
  Y = malloc(m * sizeof(uint32_t *));
  for ( int j = 0; j < m; j++ ) { 
    status = preproc_j(X[j], n, g,  &(Y[j]));  cBYE(status);
  }
  *ptr_Y = Y;
BYE:
  return status;
}
