#include "incs.h"
#include "rdtsc.h"
#include "urand.h"
int
urand(
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


int
urand2(
    int n,
    int lambda,
    float **ptr_X,
    int **ptr_Y
    )
{
  int status = 0;
  float *X = NULL;
  int   *Y = NULL;
  if ( n <= 0 ) { go_BYE(-1); }
  X = malloc(n * sizeof(float));
  return_if_malloc_failed(X);
  Y = malloc(n * sizeof(float));
  return_if_malloc_failed(Y);
  struct drand48_data buffer;
  srand48_r(RDTSC(),  &buffer);
  for ( int i = 0; i < n; i++ ) { 
    double dsum = 0; 
    int k = 0;
    for ( ; ; ) { 
      double dtemp;
      status = drand48_r(&buffer, &dtemp);
      dtemp = ( -1.0 * log(dtemp)); // note the log 
      if ( dtemp + dsum > lambda ) { 
        X[i] = dsum;
        Y[i] = k;
        break;
      }
      k++;
    }
  }

  *ptr_X = X;
  *ptr_Y = Y;
BYE:
  if ( status < 0 ) { free_if_non_null(X); free_if_non_null(Y); }
  return status;
}

