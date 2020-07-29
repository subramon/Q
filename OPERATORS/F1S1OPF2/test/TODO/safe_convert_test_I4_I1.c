#include "q_incs.h"
#include "_safe_convert_I4_I1.h"

int
main(
    )
{
  int status = 0;
#define N 20
  int32_t *X = NULL;
  int8_t *Y = NULL;
  uint64_t *Z = NULL;
  //--------MALLOC X----------------
  X = malloc(N * sizeof(int32_t));
  return_if_malloc_failed(X);
  int32_t vx = 50;
  for ( int i = 0; i < N; i++ ) {
    X[i] = vx;
    vx = vx + 20;
  }
  //---------MALLOC Y----------------
  Y = malloc(N * sizeof(int8_t));
  return_if_malloc_failed(Y);
  //---------MALLOC Y----------------
  Z = malloc(N * sizeof(uint64_t));
  return_if_malloc_failed(Z);
  //-----------TESTING-------------
  status = safe_convert_I4_I1(X, N, NULL, Y, Z);

  for ( int i = 0; i < N; i++ ) {
    uint64_t widx = i >> 8; // word index
    uint64_t bidx = i & 0xFF; // bit index
    if ( !(mcr_is_ith_bit_set(Z[widx], bidx)) ) {
      printf("FAILURE\n");
      go_BYE(-1); 
      return 1;
    }
    printf("Ok\n");
  }
  printf("CONVERT SUCCESS\n");

BYE:
  for ( int i = 0; i < N; i++ ) {
    printf("%d\n", Y[i]);
  }
  free_if_non_null(X);
  free_if_non_null(Y);
  free_if_non_null(Z);
  return status;
}
