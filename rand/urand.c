#include "incs.h"
#include "rdtsc.h"
#include "urand.h"
int
urand_1(
    int n,
    float **ptr_X
    )
{
  int status = 0;
  float *X = NULL;
  if ( n <= 0 ) { go_BYE(-1); }
  X = malloc(n * sizeof(float));
  return_if_malloc_failed(X);
  struct drand48_data buffer;
  srand48_r(RDTSC(),  &buffer);
  for ( int i = 0; i < n; i++ ) { 
    double dtemp;
    status = drand48_r(&buffer, &dtemp);
    X[i] =  (float) dtemp; 
  }

  *ptr_X = X;
BYE:
  return status;
}

int
urand_2(
    int n,
    float **ptr_X
    )
{
  int status = 0;
  float *X = NULL;
  if ( n <= 0 ) { go_BYE(-1); }
  X = malloc(n * sizeof(float));
  return_if_malloc_failed(X);
  struct drand48_data buffer;
  srand48_r(RDTSC(),  &buffer);
  for ( int i = 0; i < n; i++ ) { 
    double dtemp;
    status = drand48_r(&buffer, &dtemp);
    X[i] =  (float) ( -1.0 * log(dtemp)); // note the log 
  }

  *ptr_X = X;
BYE:
  return status;
}
