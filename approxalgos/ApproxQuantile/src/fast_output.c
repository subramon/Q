// Some bug in output which caused invalid write per Valgrind
// Need to debug it. In interim, wrote slow_output()
#include "q_incs.h"
#include "fast_output.h"

int
fast_output(
       double **buffer,      
       int *weight, 
       double *last_packet,
       int last_packet_size, 
       double *quantiles,
       int num_quantiles,
       int n, // actual number of input values 
       int b,         
       int k
       )
//-------------------------------------------------------------------------
/* README: 


This function takes as input the 2d buffer array, the weight array and
the last packet and answers quantile queries.

NOTE: you need to ensure the last packet is sorted beforehand

NOTE: Consider the following way of viewing the buffer array: each
element in a buffer occurs as many times as it's corresponding weight
in the weight array. When calling this function, the total number of
"effective" entries in the 2d buffer array and the last packet put
together is exactly n.

For example: Consider the Munro-Patterson algorithm. New() adds k
"effective" elements to the 2d buffer array for every k elements in
the input data. Collapse() doesn't alter the number of effective
elements in the 2d buffer array. Hence at this stage, the total number
of "effective" elements is equal to the total number of elements in
the input data.

INPUTS:

buffer: The 2d buffer array containing the b buffers of size k each

weight: Weight array which contains the weight information of each
buffer in the 2d buffer array

last_packet: Array containing the last packet 

last_packet_incomplete: if the last packet buffer is non-null, then
this will be 1. if the last packet in the input data is handled by
inputBuffer itself (this will happen when k (or the number of non-zero
entries in cfld) divides n), this parameter will be 0, meaning
last_packet buffer is not necessary.

last_packet_size: Size of the last packet (less than or equal to k)

n: number of elements seen by he approx_quantile function

num_quantiles: Total number of quantiles requested. For ex:
num_quantiles = 100 implies you need quantile queries every 1% from 0%
to 100%, num_quantiles = 200 implies you need quantile queries every
0.5% from 0 to 100% and so on.

b: Number of buffers in the 2d buffer array (produced by determine_b_k)

k: Size of each buffer in the 2d buffer array (produced by determine_b_k)


OUTPUTS:

quantiles: Array where the calculated quantiles are going to be stored. 

NOTE: This function is slightly different from the paper, in order to
take into consideration the last packet

*/
//--------------------------------------
{
  int status = 0;
  int *current_loc_buf = NULL;

  int last_packet_incomplete;
  if ( last_packet_size == 0 ) {  // TODO THINK
    last_packet_incomplete = 1;  
  }
  else {
    last_packet_incomplete = 0;  
  }

  /* check inputs */ 
  if ( buffer == NULL ) { go_BYE(-1); }
  if ( weight == NULL ) { go_BYE (-1); } 
  if ( quantiles == NULL ) { go_BYE(-1); }
  if ( last_packet_size > k ) { go_BYE(-1); }

  /* To calculate the quantiles from the 2d buffer array and the last
     array (which have siz number of "effective" elements, we need to
     merge and sort them first and also keep track of their
     corresponding weights. Once the merging and sorting is done, we
     can just do a sequential scan and look at each element as if it
     is occuring as many times as its corresponding weight
     ("effective" number of times) and answer all the quantile
     queries.

     This merging and sorting can be done by using a temporary 1d
     array of size (b+1)*k and another array of same size to keep
     track of their corresponding weights, but that's a waste of
     space. It can be done intelligently without using any additional
     memory by using counters current_loc_buf[b] ( and current_loc_lp
     ), current_quantile_rank and current_element_rank.

NOTE: all arrays considered here are presorted */

  current_loc_buf = (int *)malloc( b * sizeof(int)); 
  return_if_malloc_failed(current_loc_buf);
  memset(current_loc_buf, 0,  b * sizeof(int)); 
  /* keeps track of the current processing location in each buffer */
  int current_loc_lp = 0; 
  /* keeps track of current processing location in the last packet if
     it is incomplete */

  int current_proc_element_rank = 0; 
  /* keeps track of the rank of the current element being processed,
     i.e., how many "effective" elements have been processed */

  int jj = 0; 
  /* jj keeps track of estimated number of quantiles, iterates from 0 to
     num_quantile-1 */
  int next_quantile_rank = (int)ceil((jj+1)*(double)n/num_quantiles); 
  /* keeps track of the next quantile's rank to be estimated. ex: if
     next quantile to be estimated is 50%, then it would be n/2 (it
     iterates from 1*n/num_quantile to n in steps of
     n/num_quantile basically) */


  while ( true ) {

    int min_unproc_val = 0x7FFFFFFF; 
    /* stores the minimum value that has not been processed yet */
    int min_unproc_val_loc = -1; 
    /* stores the buffer id (between 0 and b-1) if the minimum
       unprocessed value is in one of those buffers, stores b if it is
       in the last packet */

    for ( int ii = 0; ii < b; ii++ ) {

      if ( weight[ii] > 0 && current_loc_buf[ii] < k ) {
        /* Only consider those buffers with corresponding weight > 0 */
        if ( buffer[ii][current_loc_buf[ii]] < min_unproc_val ) {
          min_unproc_val = buffer[ii][current_loc_buf[ii]];
          min_unproc_val_loc = ii;
        }
      }

    }
    if ( last_packet_incomplete == 1 && current_loc_lp < last_packet_size ) {

      if ( last_packet[current_loc_lp] < min_unproc_val ) {
        min_unproc_val = last_packet[current_loc_lp];
        min_unproc_val_loc = b;
      }

    }

    if ( min_unproc_val_loc < 0 ) { break; } /* done with our work */

    if ( min_unproc_val_loc < b ) {
      current_proc_element_rank += weight[min_unproc_val_loc];
      current_loc_buf[min_unproc_val_loc]++;
    }
    else if ( min_unproc_val_loc == b ) {
      current_proc_element_rank += 1; /* last packet given a weight 1 */
      current_loc_lp++;
    }
    else { go_BYE(-1); } /* something fundamentally wrong */

    while ( current_proc_element_rank >=  next_quantile_rank  && jj < num_quantiles ) {
      quantiles[jj++] = min_unproc_val;  
      next_quantile_rank = (long long) ceil((jj+1)*(double)n/num_quantiles);
    }
  }
BYE:
  free_if_non_null(current_loc_buf);
  return(status);
}
