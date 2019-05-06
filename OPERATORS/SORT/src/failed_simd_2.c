#include <inttypes.h>


int
get_bidx(
      uint16_t val, 
      uint16_t * restrict trunc_lb, 
      uint16_t * restrict trunc_ub, 
      int num_bins
      )
{
  int bidx = 0;
  uint16_t rslt = 0;
// #pragma omp simd reduction(+:rslt)
  for ( int b = 0; b < num_bins; trunc_lb++, trunc_ub++, b++ ) { 
    rslt = rslt + 
          (( ( val >= *trunc_lb ) && ( val < *trunc_ub )) << b);
  }
  bidx = __builtin_clz(rslt);
  return bidx;
}
