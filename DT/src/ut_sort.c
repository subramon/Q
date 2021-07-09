// Quick and dirty test to verify qsort_asc_val_F4_idx_I1.c
#include "incs.h"
#include "macros.h"
#include "qsort_asc_val_F4_idx_I1.h"
#include "qsort_asc_val_F4_idx_I2.h"
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int n1 = 127; // IMPORTANT: For idx_type = 1 byte, n <= 127
  int n2 = 32767; // IMPORTANT: For idx_type = 2 byte, n <= 32767
  float *X = NULL; 
  int8_t *g1 = NULL;
  int16_t *g2 = NULL;

  if ( argc == 3 ) { 
    n1 = atoi(argv[1]); if ( n1 > 127 ) { go_BYE(-1); }
    n2 = atoi(argv[2]); if ( n2 > 32767 ) { go_BYE(-1); }
  }
  printf("n1/n2 = %d/%d \n", n1, n2);

  X = malloc(n1 * sizeof(float));
  g1 = malloc(n1 * sizeof(int8_t));
  int counter = 1;
  for ( int i = 0; i < n1/2; i++ ) {
    g1[i] = counter & 0x1;
    X[i] = counter++;
  }
  for ( int i = n1/2; i < n1; i++ ) {
    g1[i] = counter & 0x1;
    X[i] = counter--;
  }
  status = qsort_asc_val_F4_idx_I1 (g1, X, n1);
  /*
  for ( int i = 0; i < n; i++ ) {
    fprintf(stdout, "%d:%f:%d\n", i, X[i], g[i]);
  }
  */
  for ( int i = 1; i < n1; i++ ) {
    if ( X[i] < X[i-1] ) { 
      go_BYE(-1);
    }
  }
  // Now test with larger index
  free_if_non_null(X);
  X  = malloc(n2 * sizeof(float));
  g2 = malloc(n2 * sizeof(int16_t));
  counter = 1;
  for ( int i = 0; i < n2/2; i++ ) {
    g2[i] = counter & 0x1;
    X[i] = counter++;
  }
  for ( int i = n2/2; i < n2; i++ ) {
    g2[i] = counter & 0x1;
    X[i] = counter--;
  }
  status = qsort_asc_val_F4_idx_I2 (g2, X, n2);
  for ( int i = 1; i < n2; i++ ) {
    if ( X[i] < X[i-1] ) { 
      go_BYE(-1);
    }
  }

  printf("%s completed successfully\n", argv[0]);
BYE:
  free_if_non_null(X);
  free_if_non_null(g1);
  free_if_non_null(g2);
  return status;
}
