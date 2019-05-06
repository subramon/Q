#include<stdio.h>
#include<stdlib.h>
#include <inttypes.h>
#include "logit_I8.h"
#include "_rdtsc.h"

int main() {
  int status = 0;
  int64_t *in_buf;
  double *out_buf;
  int start, stop = 0;
  int num_elements = 10000000;

  // Allocate memory for in_buf & out_buf
  in_buf = malloc(num_elements * sizeof("int64_t"));
  out_buf = malloc(num_elements * sizeof("double"));

  // Initialize in_buf
  for ( int i = 0; i < num_elements; i++ ) {
    in_buf[i] = 2;
    out_buf[i] = 0;
  }
  
  start = RDTSC();
  for ( int i = 0; i < 100; i++) {
    status = logit_I8(in_buf, NULL, num_elements, NULL, out_buf, NULL);
  }
  stop = RDTSC();

  printf("logit execution time C = %d\n", stop-start);

  printf("Done\n");
  return status;
}
