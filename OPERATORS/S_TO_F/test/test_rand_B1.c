#include "q_incs.h"
#include "rand_B1.h"
#include "_rdtsc.h"

int main(
    ) 
{
  int status = 0;
  int n = 1048576+8;
  void *Y = malloc(n);
  uint8_t *X = (uint8_t *) Y;
  memset(X, '\0', n);
  RAND_B1_REC_TYPE args;
  double p = 0.02;
  args.seed = 0;
  args.probability = p;

  int m = 1048576+3;
  status = rand_B1((uint64_t *)X, m, &args, 0); cBYE(status);
  int actual_cnt = 0;
  for ( int i = 0; i < n; i ++ ) { 
    actual_cnt += __builtin_popcountll(X[i]);
  }
  int theoretical_cnt = (int)(m * args.probability);
  printf("m = %d, p = %lf, Theory = %d, Actual = %d \n", 
      m, p, theoretical_cnt, actual_cnt);
  if ( ( actual_cnt > theoretical_cnt * 1.01 ) || 
       ( actual_cnt < theoretical_cnt * 0.99 ) ) {
    go_BYE(-1);
  }

BYE:
  free_if_non_null(Y);
  return status;
}
