#include "q_incs.h"
#include <strings.h>
#include <math.h>
#include "_cum_for_dt_F4_I4.h"

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int nF = 1024;
  int chunk_size = 64;
  int ng = 2;
  float *F = malloc(nF * sizeof(float));
  int   *G = malloc(nF * sizeof(int));
  float *V = malloc(nF * sizeof(float));
  int32_t **cnts = malloc(ng * sizeof(int32_t *));
  for ( int i = 0; i < ng; i++ ) { 
    cnts[i] = malloc(nF * sizeof(int32_t));
  }

  int min_repeat = 1;
  int max_repeat = 8;
 
  int repeat = min_repeat;
  int fidx = 0;
  float fval = 1;
  for ( ; ; ) { 
    for ( int repeat = min_repeat; repeat < max_repeat; repeat++ ) { 
      for ( int i = 0; i < repeat; i++ ) { 
        F[fidx] = fval;
        G[fidx] = random() % ng;
        fidx++;
        if ( fidx >= nF ) { break; }
      }
      fval++;
      if ( fidx >= nF ) { break; }
    }
    if ( fidx >= nF ) { break; }
  }
  // for ( int i = 0; i < nF; i++ ) { printf("%f,%d\n", F[i], G[i]); }
  int num_blocks = nF / chunk_size;
  if ( num_blocks * chunk_size < nF ) {
    num_blocks++;
  }
  uint64_t aidx = 0;
  uint64_t num_in_V = 0;
  uint64_t nV = chunk_size;
  for ( int b = 0; b < num_blocks; b++ ) { 
    bool is_first;
    int lb = b * chunk_size;
    int ub = lb + chunk_size;
    if ( ub > nF ) { ub = nF; }
    uint64_t n_in = ub - lb;
    if ( b == 0 ) { is_first = true; } else { is_first = false; }
    status = cum_for_dt_F4_I4(is_first, F+lb, G+lb, ng,  &aidx, n_in,
        V, cnts, nV, &num_in_V);
    cBYE(status);
  }
BYE:
  free_if_non_null(F);
  free_if_non_null(V);
  free_if_non_null(G);
  if ( cnts != NULL ) { 
    for ( int i = 0; i < ng; i++ ) { 
      free_if_non_null(cnts[i]);
    }
    free_if_non_null(cnts);
  }
}
