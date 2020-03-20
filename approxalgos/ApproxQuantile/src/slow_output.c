#include "q_incs.h"
#include "slow_output.h"

typedef struct _rec_t { 
  double val;
  int wt;
} rec_t;

static int
sortcompare(
    const void *p1, 
    const void *p2
    )
{
  rec_t *r1 = (rec_t *)(p1);
  rec_t *r2 = (rec_t *)(p2);
  if ( r1->val > r2->val ) {
    return 1;
  }
  else {
    return 0;
  }
}

int
slow_output(
       double **buffer,      
       int *weight, 
       double *last_packet,
       int n_last_packet, 
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
  rec_t *final = NULL;  int n_final = 0;

  /* check inputs */ 
  if ( buffer == NULL ) { go_BYE(-1); }
  if ( weight == NULL ) { go_BYE (-1); } 
  if ( quantiles == NULL ) { go_BYE(-1); }
  if ( n < 1 ) { go_BYE(-1); }
  if ( k < 1 ) { go_BYE(-1); }
  if ( b < 1 ) { go_BYE(-1); }
  if ( n_last_packet > k ) { go_BYE(-1); }
  if ( n_last_packet < 0 ) { go_BYE(-1); }

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
     space. We deliberately avoid doing anything fancier */

  n_final = (b * k) + n_last_packet;
  final = malloc(n_final * sizeof(rec_t));
  return_if_malloc_failed(final);
  memset(final, 0,  n_final * sizeof(rec_t));

  int fidx = 0;
  for ( int bidx = 0; bidx < b; bidx++ ) { 
    for ( int kidx = 0; kidx < k; kidx++ ) { 
      if ( fidx >= n_final ) { go_BYE(-1); }
      final[fidx].val = buffer[bidx][kidx];
      final[fidx].wt  = weight[bidx];
      fidx++;
    }
  }
  for ( int i = 0; i < n_last_packet; i++ ) { 
    if ( fidx >= n_final ) { go_BYE(-1); }
    final[fidx].val  = last_packet[i];
    final[fidx].wt   = 1;
    fidx++;
  }
  qsort(final, n_final, sizeof(rec_t), sortcompare);
  int qidx = 0; 
  double n_per_quantile = n / (num_quantiles+1);
  double cum_wt = 0;
  double chk_wt = 0;
  for ( int i = 0; i < n_final; i++ ) { 
    chk_wt += final[i].wt;
  }
  for ( int i = 0; i < n_final; i++ ) { 
    cum_wt += final[i].wt;
    if ( cum_wt >= (qidx+1) * n_per_quantile ) { 
      if ( qidx >= num_quantiles ) { break; }
      quantiles[qidx] = final[i].val;
      qidx++;
      if ( qidx == num_quantiles ) { break; }
    }
  }
BYE:
  free_if_non_null(final);
  return status;
}
