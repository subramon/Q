#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "../gen_src/_period_F8.c"

int main() {
  int status = 0;
  int n = 11;
  double *X = malloc(n*sizeof(double));
  PERIOD_F8_REC_TYPE args;
  args.start = 1.5;
  args.by = 0.25;
  args.period = 5;

  status = period_F8(X, n, &args, 0);

  for ( int i = 0; i < n; i++ ) { 
    printf("%lf ", X[i]);
  }
  return status;
}
