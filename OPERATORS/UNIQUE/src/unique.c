#include "q_incs.h"

int
unique(
      const int32_t * restrict A,
      uint64_t nA,
      uint64_t *ptr_aidx,
      int32_t *C,
      uint64_t nC,
      uint64_t *ptr_num_in_C
      )
{
  int status = 0;
  
  if ( A == NULL ) { go_BYE(-1); }
  if ( nA == 0 ) { go_BYE(-1); }
  if ( ptr_num_in_C == NULL ) { go_BYE(-1); }
  if ( ptr_aidx == NULL ) { go_BYE(-1); }

  uint64_t num_in_C = *ptr_num_in_C;
  uint64_t aidx = *ptr_aidx;
  if ( num_in_C > nC ) { go_BYE(-1); }
  
  for ( ; aidx < nA-1; aidx++ ) { 
    if ( num_in_C == nC ) { break; }
    if ( A[aidx] != A[aidx+1] ) {
      C[num_in_C++] = A[aidx];
      }
    }
  // Include last element
  C[num_in_C++] = A[nA-1];
  *ptr_num_in_C = num_in_C;
  *ptr_aidx     = aidx+1;
BYE:
  return status;
}

int main() {
  int status = 0;
  int size = 10;
  int32_t *in_buf, *out_buf;
  uint64_t *num_in_out, *aidx;

  // Allocate memory for in_buf & out_buf
  in_buf = malloc(size * sizeof("int32_t"));
  out_buf = malloc(size * sizeof("int32_t"));
  num_in_out = malloc(sizeof("uint64_t"));
  aidx = malloc(sizeof("uint64_t"));
  aidx[0] = 0;
  
  // Initialize in_buf
  printf("Input buffer is\n");
  for ( int i = 0; i < size; i++ ) {
    in_buf[i] = i+1;
    if ( i == 4 ) {
      in_buf[i] = 4;
    }
    else if ( i == 9 ) {
      in_buf[i] = 9;
    }
    printf("%d\n", in_buf[i]);
  }

  // Call to unique
  status = unique(in_buf, size, aidx, out_buf, size, num_in_out);

  printf("Unique elements in out_buf = %ld\n", *num_in_out);
  for ( int i = 0; i < *num_in_out; i++ ) {
    printf("%d\n", out_buf[i]);
  }
  return status;
}
