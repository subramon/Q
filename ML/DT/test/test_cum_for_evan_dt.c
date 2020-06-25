#include "q_incs.h"
#include <strings.h>
#include <math.h>
#include "_cum_for_evan_dt_F4_I4.h"

#define FTYPE float
#define GTYPE int32_t
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int nF = 1024;
  int chunk_size = 64;
  FTYPE *F = malloc(nF * sizeof(FTYPE)); // input 
  GTYPE   *G = malloc(nF * sizeof(GTYPE)); // input 
  FTYPE *V = malloc(nF * sizeof(FTYPE)); // output 
  double *S = malloc(nF * sizeof(double)); // output 
  uint32_t *N = malloc(nF * sizeof(uint32_t)); // output 

  int min_repeat = 1;
  int max_repeat = 8;
 
  int repeat = min_repeat;
  int fidx = 0;
  float fval = 1;
  for ( ; ; ) { 
    for ( int repeat = min_repeat; repeat < max_repeat; repeat++ ) { 
      for ( int i = 0; i < repeat; i++ ) { 
        F[fidx] = fval;
        G[fidx] = (int32_t)fval;
        fidx++;
        if ( fidx >= nF ) { break; }
      }
      fval++;
      if ( fidx >= nF ) { break; }
    }
    if ( fidx >= nF ) { break; }
  }
  // confirmt that F is sorted ascending
  for ( int i = 1; i < nF; i++ ) { 
    if ( F[i] < F[i-1] ) { go_BYE(-1); }
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
    status = cum_for_evan_dt_F4_I4(is_first, F+lb, G+lb, &aidx, n_in,
        V, S, N, nV, &num_in_V);
    cBYE(status);
    if ( aidx == n_in ) { aidx = 0; }
    // TODO: Need to test case of input and output not being 
    // consumed/produced evenly
  }
  /*
  fval = 1;
  int vidx = 0;
  int exp_total = min_repeat;
  for ( ; ; vidx++ ) {
    if ( V[vidx] != fval ) { go_BYE(-1); }
    int total = 0;
    for ( int i = 0; i < ng; i++ ) { 
      total += cnts[i][vidx];
    }
    if ( total != exp_total ) { go_BYE(-1); }
    exp_total++;
    if ( exp_total > max_repeat ) { exp_total = min_repeat; }
    if ( V[vidx] == F[nF-1] ) { break; }
    fval++;
  }
  */

BYE:
  free_if_non_null(F);
  free_if_non_null(G);
  free_if_non_null(V);
  free_if_non_null(S);
  free_if_non_null(N);
}
