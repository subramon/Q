// Quick and dirty test to verify qsort_asc_val_F4_idx_I1.c
#include "incs.h"
#include "macros.h"
#include "qsort_asc_val_F4_idx_I1.h"
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int n = 65;
  float *X = NULL; int8_t *g = NULL;
  X = malloc(n * sizeof(float));
  g = malloc(n * sizeof(int8_t));
  int counter = 1;
  for ( int i = 0; i < n/2; i++ ) {
    g[i] = counter & 0x1;
    X[i] = counter++;
  }
  for ( int i = n/2; i < n; i++ ) {
    g[i] = counter & 0x1;
    X[i] = counter--;
  }
  status = qsort_asc_val_F4_idx_I1 (g, X, n);
  for ( int i = 0; i < n; i++ ) {
    fprintf(stdout, "%d:%f:%d\n", i, X[i], g[i]);
  }
  printf("%s completed successfully\n", argv[0]);
BYE:
  free_if_non_null(X);
  free_if_non_null(g);
  return status;
}
