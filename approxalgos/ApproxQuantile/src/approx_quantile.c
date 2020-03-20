#include "q_incs.h"
#include "qsort_asc_F8.h"
#include "approx_quantile.h"
#include "determine_b_k.h"
#include "New.h"
#include "Collapse.h"
#include "Output.h"

int 
approx_quantile_make(
    int num_quantiles,
    uint64_t n_input_vals_estimate,
    approx_quantile_state_t *ptr_state,
    double eps,
    int *ptr_error_code
    )
{
  int status = 0;
  *ptr_error_code = 0;

  /* Check inputs */
  if ( ( eps < 0 )  || ( eps > 1 ) ) { go_BYE(-1); }
  if ( num_quantiles < 1 ) { go_BYE(-1); }

  //----------------------------------------------------------------------

  /* "buffer" is a 2d array containing b buffers, each of size k. Each
     of these b buffers have a weight assigned to them, which will be
     stored in "weight" array of size b. Consider the following way of
     viewing the 2d buffer array: each element in a buffer
     "effectively" occurs as many times as it's corresponding weight
     in the weight array. The algorithm compresses the whole input
     data into these buffers by using "approximate" entries instead of
     actual entries so that the total number of distinct entries comes
     down significantly (uses a total memory of ~ b*k, which is
     typically << eff_siz, the price paid being approximation). This
     approximation is done intelligently so that very good and useful
     theoretical quantile guarantees can be provided */


  if ( n_input_vals_estimate == 0 ) { // TODO THINK!!!
    n_input_vals_estimate = 1048576; 
  } 
  int b;
  int k; 
  status = determine_b_k(eps, n_input_vals_estimate, &b, &k);  cBYE(status);
  /* estimates b and k for the given eps and eff_siz */

  if ( ( b <= 0 ) || ( k <= 0 ) ) {
    *ptr_error_code = EPS_OR_SIZ_BAD;
    go_BYE(-1); /* Something wrong with the inputs eps or siz */ 
  }
  //------------------------
  if ( (b+1+10)*k > MAX_SZ ) {
    /* (b+1+10)*k a good upper bound of the memory requirements */
    *ptr_error_code = SIZ_INCONSISTENT_WITH_EPS;
    go_BYE(-1);
    /* Quitting if too much memory needed. Retry by doing one or more
       of the following: (i) Increase MAX_SZ if you think you have
       more RAM (ii) Increase eps (the approximation percentage) so
       that computations can be done within RAM
       */
  } 
  ptr_state->n_input_vals_estimate = n_input_vals_estimate;
  ptr_state->is_final = false;
  ptr_state->b = b;
  ptr_state->k = k;
  ptr_state->eps = eps;
  ptr_state->num_quantiles = num_quantiles;
  ptr_state->buffer = NULL;
  ptr_state->weight = NULL;
  ptr_state->quantiles = NULL;
  ptr_state->num_empty_buffers = b;

  ptr_state->buffer      = malloc(b * sizeof(double *) ); 
  return_if_malloc_failed(ptr_state->buffer);
  memset(ptr_state->buffer, 0, b * sizeof(double *) ); 

  ptr_state->weight      = malloc( b * sizeof(int) ); 
  return_if_malloc_failed(ptr_state->weight);
  memset(ptr_state->weight, 0, b * sizeof(int) ); 

  ptr_state->quantiles      = malloc( b * sizeof(int) ); 
  return_if_malloc_failed(ptr_state->quantiles);
  memset(ptr_state->quantiles, 0, b * sizeof(int) ); 

  for ( int ii = 0; ii < b; ii++ ) {
    ptr_state->buffer[ii] = (double *) malloc( k * sizeof(double) );
    return_if_malloc_failed(ptr_state->buffer[ii]);
    memset(ptr_state->buffer[ii], 0, k * sizeof(double) );
  }

  ptr_state->in_buffer      = malloc(k * sizeof(double)); 
  return_if_malloc_failed(ptr_state->in_buffer);
  ptr_state->n_in_buffer    = 0;
BYE:
  return status;
}
//----------------------------------------------------------------------
static int 
approx_quantile_exec(
    approx_quantile_state_t *ptr_state
    )
{
  int status = 0;
  int b = ptr_state->b;
  int k = ptr_state->k;
  int *weight = ptr_state->weight;
  double **buffer = ptr_state->buffer;
  if ( ptr_state->k != ptr_state->n_in_buffer ) { go_BYE(-1); }
  //---------------------------------------------------------------------

  /* The Munro-Patterson algorithm assumes that the incoming data is
     in the form of packets of size k with sorted data. */
  /* 
     (1) Sort the packet.

     (2) Check if a buffer in the 2d buffer array is free (i.e., some
     buffer has weight = 0 )

     (3a) If yes, copy the packet to a free buffer in the buffer array
     using New() function.

     (3b) If no, use Collapse() function to merge two buffers in the
     buffer array which have the same weight and free up one buffer
     in the process (and copy the packet to that buffer)
     */

  qsort_asc_F8(ptr_state->in_buffer, k); // Step 1 of above

  // Steps (2) + 3(b)

  /* if no free buffer available in the 2d buffer array , merge data in 2 buffers having same weight into one of them using Collapse() and free up other */
  if ( ptr_state->num_empty_buffers == 0 ) {
    int bufidx1 = -1, bufidx2 = -1; 
    /* find 2 buffers with same corresponding weight in the weight array */
    for ( int ii = 0; ii < b-1; ii++ ) { 
      if ( weight[ii] <= 0 ) { go_BYE(-1); } // 'cos no free buffers
      for ( int jj = ii+1; jj < b; jj++ ) {
        if ( weight[ii] == weight[jj] ) { bufidx1 = ii; bufidx2 = jj; break; }
      }
      if ( bufidx1 >= 0 ) { break; }
    } 
    if ( ( bufidx1 < 0 ) ||  ( bufidx2 < 0 ) ) { go_BYE(-1); }
    /* Merge buffer numbers [bufidx1] and [bufidx2] */
    status = Collapse(buffer[bufidx1], buffer[bufidx2], weight, 
        bufidx1, bufidx2, b, k);  
    cBYE(status);
    ptr_state->num_empty_buffers = 1;
  }
  // Step 2 + 3(a) 
  if ( ptr_state->num_empty_buffers == 0 ) { go_BYE(-1); }
  /* find a free buffer (corresponding weight = 0 in the weight array) */
  int bufidx1 = -1;
  for ( int ii = 0; ii < b; ii++ ) {
    if ( weight[ii] == 0 ) { bufidx1 = ii; break; }
  } 
  if ( bufidx1 < 0 ) { go_BYE(-1); }
  /* Copy current input packet into a free buffer in the 2d buffer array*/
  status = New(ptr_state->in_buffer, buffer[bufidx1], weight, 1,
      bufidx1, b, k);
  cBYE(status);
  ptr_state->num_empty_buffers--; // one less free buffer

  ptr_state->n_in_buffer = 0; // flushed the in buffer
BYE:
  return status;
}
//-----------------------------------------------
int 
approx_quantile_add(
    approx_quantile_state_t *ptr_state,
    double val
    )
{
  int status = 0;
  if ( ptr_state->is_final) { go_BYE(-1); }
  ptr_state->n_input_vals++;
  if ( ptr_state->n_in_buffer < ptr_state->k ) {
    ptr_state->in_buffer[ptr_state->n_in_buffer] = val;
    ptr_state->n_in_buffer++;
  }
  if ( ptr_state->n_in_buffer < ptr_state->k ) { return status; }
  status = approx_quantile_exec(ptr_state); cBYE(status);
BYE:
  return status;
}
//----------------------------------------------------------------------
int 
approx_quantile_free(
    approx_quantile_state_t *ptr_state
    )
{
  int status = 0;
  free_if_non_null(ptr_state->quantiles);
  free_if_non_null(ptr_state->weight);
  free_if_non_null(ptr_state->in_buffer);
  if ( ptr_state->buffer != NULL ) { 
    for ( int i = 0; i < ptr_state->b; i++ ) { 
      free_if_non_null(ptr_state->buffer[i]);
    }
    free_if_non_null(ptr_state->buffer);
  }
  return status;
}
//-------------------------------------------------------
int 
approx_quantile_final(
    approx_quantile_state_t *ptr_state
    )
{
  int status = 0; 
  int k             = ptr_state->k;
  int b             = ptr_state->b;
  int n_in_buffer   = ptr_state->n_in_buffer;
  double *in_buffer = ptr_state->in_buffer;
  double **buffer   = ptr_state->buffer;
  int *weight       = ptr_state->weight;
  double *quantiles = ptr_state->quantiles;
  int num_quantiles = ptr_state->num_quantiles;
  int n             = ptr_state->n_input_vals;

  ptr_state->is_final = true;
  if ( n_in_buffer < k ) {
    qsort_asc_F8(in_buffer, n_in_buffer);
  }
  //----------------------------------------------------------------------
  /* Final quantile computations using data from 2d buffer array,
     weight array and last packet (if it exists) */

  status = Output(buffer, weight, in_buffer, n_in_buffer, quantiles, 
      num_quantiles, n, b, k); 
  cBYE(status);
  //---------------------------------------------------------------------

BYE:
  return status;
}
//--------------------------------------------------------------------------
/* README:

status = approx_quantile(x,
siz,num_quantiles,eps,y,ptr_estimate_is_good): Calculates the
approximate quantiles of an integer set using very little memory.

For example: If you request for 10 quantiles with eps of 0.001: {10%,
20%,...90%, 100% } quantiles will be answered with an error of +/0.1%
i.e., 10% quantile will be definitely between 9.9% and 10.1%, 90%
quantile will definitely be between 89.9% and 90.1%.

Author: Kishore Jaganathan

Algorithm: Munro-Patterson Algorithm by G.S.Manku ("Approximate
Medians and other Quantiles in One Pass with Limited Memory")

INPUTS: 

x: Array containing the input data to be processed.

siz: Number of elements in the input array x. 

num_quantiles: Number of quantiles that have to be calculated (1 <=
num_quantiles <= siz).  For ex: num_quantiles = 100 implies you need
quantile queries every 1% from 1% to 100%, num_quantiles = 200 implies
you need quantile queries every 0.5% from 0.5% to 100% and so on (try
100 if you don't know what to use).

eps: Acceptable error in the calculated quantiles (0 <= eps <= 1). For
example, eps = 0.001 would imply +/- 0.1%, eps = 0.0001 would imply
+/- 0.01% (try 0.001 if you don't know what to use).

OUTPUTS: 

y: Array where the quantile summary is going to be stored

ptr_estimate_is_good: Pointer to the location with values 1, -1 or -2, which stand for the following
1: For the given inputs siz and eps, approximate quantile calculations are possible. The computations are done and results are stored in y.
-1: Something wrong with the inputs.
-2: For the given inputs siz and eps, approximate quantile calculations are not possible within the memory constraints. Retry with: 
(i) a higher value for MAX_SZ defined in this function if you know you have more RAM available 
(ii)a higher value for eps (i.e., more approximation) so that the computations can be done in memory 

status: takes values -1 or 0
0: The algorithm either computed the quantiles and set *ptr_estimate_is_good to 1 or the computations are not possible for the given eps and siz and set *ptr_estimate_is_good to -2.
-1: Something wrong with the inputs, *ptr_estimate_is_good is set to -1.
 
*/

//------------------------------------------------------------------------
