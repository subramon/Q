#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>
#include "incs.h"
#include "urand.h"
#include "poisson.h"
#include "rdtsc.h"

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  
  float *X = NULL;
  int *P1 = NULL; int *hP1 = NULL; 
  int *G  = NULL; int *hG  = NULL; 
  const gsl_rng_type * T = NULL;
  gsl_rng * r = NULL;
  int num_steps;
  float lambda;
  int M, N;

  if ( argc != 3 ) { go_BYE(-1); }
  lambda = atof(argv[1]);
  if ( lambda <= 0 ) { go_BYE(-1); };

  M = atoi(argv[2]);
  if ( M <= 0 ) { go_BYE(-1); };
  N = M / 4;
  
  P1 = malloc(M * sizeof(int)); return_if_malloc_failed(P1);
  G  = malloc(M * sizeof(int)); return_if_malloc_failed(G);
  status = urand_1(N, &X); cBYE(status);
  int ridx = 0;
  uint64_t t1 = RDTSC();
  int p1_num_steps = 0;
  for ( int i = 0; i < M; i++ ) { 
   P1[i] = poisson_1(lambda, X, N, &ridx, &num_steps); cBYE(status);
   p1_num_steps += num_steps;
  }
  uint64_t t2 = RDTSC();

  uint64_t t3 = RDTSC();
  // set up stuff for random number generation
  T = gsl_rng_default;
  r = gsl_rng_alloc (T);
  for ( int i = 0; i < M; i++ ) { 
   G[i] = gsl_ran_poisson(r, lambda); cBYE(status);
  }
  uint64_t t4 = RDTSC();

  int maxval = 0;
  for ( int i = 0; i < M; i++ ) { 
    if ( P1[i] > maxval ) { maxval = P1[i]; }
    if (  G[i] > maxval ) { maxval = G[i]; }
  }
  hP1 = malloc((maxval+1) * sizeof(int));
  hG  = malloc((maxval+1) * sizeof(int));
  for ( int i = 0; i <= maxval; i++ ) { 
    hG[i] = hP1[i] = 0;
  }
  for ( int i = 0; i < M; i++ ) { 
    hP1[P1[i]]++;
    hG[G[i]]++;
  }
  fprintf(stderr, "idx,alt,gsl\n"); 
  for ( int i = 0; i <= maxval ; i++ ) { 
    fprintf(stderr, "%3d,%d,%d\n", i, hP1[i], hG[i]);
  }
  printf("P1 = %" PRIu64 ", num steps = %d \n", t2-t1, p1_num_steps);
  printf("G  = %" PRIu64 "\n", t4-t3);

BYE:
  if ( r != NULL ) { gsl_rng_free(r); }
  free_if_non_null(X);
  free_if_non_null(P1); free_if_non_null(hP1);
  free_if_non_null(G); free_if_non_null(hG);
  return status;
}

