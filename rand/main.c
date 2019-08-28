#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>
#include "incs.h"
#include "urand.h"
#include "poisson.h"
#include "rdtsc.h"

int
main()
{
  int status = 0;
  int N = 1048576;
  float *X = NULL;
  int *Y = NULL; int *hY = NULL; 
  int *Z = NULL; int *hZ = NULL; 
  const gsl_rng_type * T = NULL;
  gsl_rng * r = NULL;

  int M = N * 16;
  Y = malloc(M * sizeof(int)); return_if_malloc_failed(Y);
  Z = malloc(M * sizeof(int)); return_if_malloc_failed(Z);
  status = urand(N, &X); cBYE(status);
  float lambda = 5;
  int ridx = 0;
  uint64_t t1 = RDTSC();
  for ( int i = 0; i < M; i++ ) { 
   Y[i] = poisson(lambda, X, N, &ridx); cBYE(status);
  }
  uint64_t t2 = RDTSC();
  printf("1 = %" PRIu64 "\t, ridx = %d\n", t2-t1, ridx);
  // set up stuff for random number generation
  T = gsl_rng_default;
  r = gsl_rng_alloc (T);
  for ( int i = 0; i < M; i++ ) { 
   Z[i] = gsl_ran_poisson(r, lambda); cBYE(status);
  }
  uint64_t t3 = RDTSC();
  printf("2 = %" PRIu64 "\n", t3-t2);
  int maxval = 0;
  for ( int i = 0; i < M; i++ ) { 
    if ( Y[i] > maxval ) { maxval = Y[i]; }
    if ( Z[i] > maxval ) { maxval = Z[i]; }
  }
  hY = malloc((maxval+1) * sizeof(int));
  hZ = malloc((maxval+1) * sizeof(int));
  for ( int i = 0; i <= maxval; i++ ) { 
    hY[i] = hZ[i] = 0;
  }
  for ( int i = 0; i < M; i++ ) { 
    hY[Y[i]]++;
    hZ[Z[i]]++;
  }
  for ( int i = 0; i <= maxval ; i++ ) { 
    fprintf(stderr, "%3d: %8d %8d \n", i, hY[i], hZ[i]);
  }
  

BYE:
  if ( r != NULL ) { gsl_rng_free(r); }
  return_if_malloc_failed(X);
  return_if_malloc_failed(Y);
  return_if_malloc_failed(Z);
  return status;
}

