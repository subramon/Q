#include "q_incs.h"
#include "determine_b_k.h"

//START_FUNC_DECL
int
determine_b_k(
	      double eps,  
	      uint64_t siz, 
	      uint32_t *ptr_b,  
	      uint32_t *ptr_k  
	      )
//STOP_FUNC_DECL
//---------------------------------------------------------------------------
/* README:

determine_b_k (err,siz,ptr_b,ptr_k): This function calculates b and k values for a given data size and acceptable error percentage. b is the number of buffers and k is the size of each buffer in the 2d buffer array.

INPUTS: 

err: Acceptable error percentage in the quantile calculations. ex: 0.001 implies +/- 0.1% and so on.

siz: Size of the input data

OUTPUTS:

ptr_b: Pointer to the location which tells you how many buffers to use in the 2d buffer array (b)

ptr_k: Pointer to the location which tells you the size of each buffer in the 2d buffer array (k)

*/

//---------------------------------------------------------------------------
{
  int status = 0;
  int b = -1;
  uint64_t k;

  b = 2; 
  while ( ((b-2)*pow(2,b-2)+1) < (double)(eps*siz) ) {
    b++;
  }
  b--;
  if ( b <= 0 ) { go_BYE(-1); }

  if ( (siz % (uint64_t)pow(2,b-1)) == 0 ) {
    k = siz/pow(2,b-1);
  }
  else {
    k = siz/pow(2,b-1)+1;
  }
  if ( k >  INT_MAX ) { go_BYE(-1); } // we return a signed integer
  if ( k <= 0 ) { go_BYE(-1); } 

  /* TODO: Improve documentation here. We set k to a minimum size since 
   * we will give each thread k items to sort in parallel */
  if ( k < 16384 ) { k = 16384; } 

  *ptr_b = (uint32_t)b;
  *ptr_k = (uint32_t)k;

BYE:
  return status;
}
