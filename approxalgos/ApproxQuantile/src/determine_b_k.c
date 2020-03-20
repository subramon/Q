#include "q_incs.h"
#include "determine_b_k.h"

int
determine_b_k(
	      double eps,  
	      uint64_t n_input_vals_estimate, 
	      int *ptr_b,  
	      int *ptr_k  
	      )
//---------------------------------------------------------------------------
/* README:


This function calculates b and k values for a given data size and
acceptable error percentage. b is the number of buffers and k is the
size of each buffer in the 2d buffer array.

INPUTS: 

err: Acceptable error percentage in the quantile calculations. ex:
0.001 implies +/- 0.1% and so on.

n_input_vals_estimate: estimate of size of the input data

OUTPUTS:

ptr_b: Pointer to the location which tells you how many buffers to use
in the 2d buffer array (b)

ptr_k: Pointer to the location which tells you the size of each buffer
in the 2d buffer array (k)

*/

//------------------------------------------------------------------------
{
  int status = 0;
  int b = -1;
  long long k = -1;

  b = 2; 
  while ( ((b-2)*pow(2,b-2)+1) < (double)(eps*n_input_vals_estimate) ) {
    b++;
  }
  b--;

  if ( (n_input_vals_estimate % (long long)pow(2,b-1)) == 0 ) {
    k = n_input_vals_estimate/pow(2,b-1);
  }
  else {
    k = n_input_vals_estimate/pow(2,b-1)+1;
  }

  *ptr_b = b;
  *ptr_k = k;

  return status;
}
