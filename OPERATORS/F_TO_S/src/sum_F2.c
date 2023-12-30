#include "sum_struct.h"
#include "sum_B1.h"
#include "qtypes.h" // for bfloat16
int
sum_F2(  
      const bfloat16  * restrict in,  
      uint32_t nR,
      SUM_F_ARGS *ptr_args,
      uint32_t idx
      ) 
{
  int status = 0;
  
  uint32_t nT = sysconf(_SC_NPROCESSORS_ONLN);
  uint32_t block_size = nR / nT;
  double gsum = 0;
#pragma omp parallel for schedule(static)
  for ( uint32_t t = 0; t < nT; t++ ) { 
    uint32_t lsum = 0;
    uint32_t lb = t * block_size;
    uint32_t ub = lb + block_size;
    if ( t == 0      ) { lb = 0;       }
    if ( t == (nT-1) ) { ub = nR; }
    for ( uint32_t i  = lb; i < ub; i++ ) {  
      float ftmp = F2_to_F4(in[i]);
      lsum += ftmp;
    }
#pragma omp critical (_sum_B1)
    {
      gsum += lsum;
    }
  }
  ptr_args->val += gsum;
  ptr_args->num += nR;
  return status;
}
