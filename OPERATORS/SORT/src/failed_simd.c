#include <inttypes.h>

#pragma omp declare simd
int
min(
    int x,
    int y
   )
{
  return x < y ? x : y;
}

int
get_bidx(
      uint16_t val, 
      uint16_t *trunc_lb, 
      uint16_t *trunc_ub, 
      int num_bins
      )
{
  int bidx = 0;
#pragma omp simd reduction(min:bidx)
  for ( int b = 0; b < num_bins; b++ ) {
    bidx = min(
        bidx, 
        ( 
          b & 
          ( ( val >= trunc_lb[b] ) && ( val < trunc_ub[b] ))));
  }
  return bidx;
}
