#include "incs.h"
#include "rs_mmap.h"
#include "read_data.h"

int 
read_data(
    float ***ptr_X, /* [m][n] */
    uint32_t m,
    uint32_t n,
    uint8_t **ptr_g,
    const char * const bin_file_prefix
   )
{
  int status = 0;
  float **X = NULL; 
  uint8_t *g = NULL;
  char *file_name = NULL;
  char *Y = NULL; size_t nY = 0;

  int len = strlen(bin_file_prefix)+64;
  file_name = malloc(len);

  X = malloc(m * sizeof(float));
  return_if_malloc_failed(X);
  for ( uint32_t i = 0; i < m; i++ ) { 
    sprintf(file_name, "%s_feature_%d.bin", bin_file_prefix, i);
    status = rs_mmap(file_name, &Y, &nY, 0); cBYE(status);
    if ( nY != (n * sizeof(float) ) ) { go_BYE(-1); }
    X[i] = (float *)Y;
  }
  sprintf(file_name, "%s_goal.bin", bin_file_prefix);
  status = rs_mmap(file_name, &Y, &nY, 0); cBYE(status);
  if ( nY != (n * sizeof(uint8_t) ) ) { go_BYE(-1); }
  g = (uint8_t  *)Y;

  *ptr_X = X;
  *ptr_g = g;
BYE:
  return status;
}
