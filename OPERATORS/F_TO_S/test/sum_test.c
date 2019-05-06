#include <stdio.h>
//#include "../gen_src/_sum_I4.c"
#include "../gen_inc/_sum_I4.h"

int main() {
  int status = 0;
  int n = 100000;
  for ( int i = 0; i < 10; i++ ) {
    int32_t x[n];
    for ( int32_t j = 1; j <= n; j++ ) {
      x[(int)j] = j;
    }
    REDUCE_sum_I4_ARGS args;
    int chunk_size = 64 * 1024;

    for( uint64_t k = 0; k < 2; k++ ) {
      int len;
      if ( k == 1 ) {
        len = n % chunk_size;
      }
      else {
        len = chunk_size;
      }
      status = sum_I4( x, len, &args, k);
    }
    printf("%lf\n", args.sum_val);
  }
  return status;
}



