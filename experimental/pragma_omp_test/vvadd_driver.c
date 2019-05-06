#include<stdio.h>
#include<stdlib.h>
#include "vvadd_I4_I4_I4.h"
#include "_get_time_usec.h"

int main() {
  int status = 0;
  int chunk_size = 16 * 1024;
  int size = chunk_size * 2;
  int number_of_chunks = ceil((double)size/chunk_size);
  int32_t *in_buf1, *in_buf2, *out_buf;
  int offset = 0;
  int itr_count = 10000;
  int start, total_time = 0;

  // Allocate memory for in_buf1, in_buf2 & out_buf
  in_buf1 = malloc(size * sizeof("int32_t"));
  in_buf2 = malloc(size * sizeof("int32_t"));
  out_buf = malloc(size * sizeof("int32_t"));

  // Initialize in_buf
  for ( int i = 0; i < size; i++ ) {
    in_buf1[i] = i+1;
    in_buf2[i] = i+1;
    out_buf[i] = 0;
  }
  
  while ( itr_count > 0 ) {
    for ( int i = 0; i < number_of_chunks; i++) {
      offset = i * chunk_size;
      start = get_time_usec();
      status = vvadd_I4_I4_I4(in_buf1 + offset, in_buf2 + offset, size, out_buf + offset);
      total_time = total_time + ( get_time_usec() - start );
      //printf("Status = %d\n", status);
    }
    itr_count--;
  }

  printf("vvadd execution time = %d\n", total_time);

  // Validation
  int exp_result = (size * (size + 1) / 2) * 2;
  int sum = 0;
  for ( int i = 0; i < size; i++ ) {
    sum = sum + out_buf[i];
  }
  if ( sum == exp_result ) {
    printf("VVADD Successful\n");
  }
  else {
    printf("VVADD FAILED");
  }

  printf("VVADD Done !!\n");
  return status;
}
