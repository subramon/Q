#include "q_incs.h"
#include "qsort_asc_F8.h"
#include "approx_frequent_struct.h"
#include "approx_frequent.h"
#include "sorted_array_to_id_freq.h"
#include "update_counter.h"

#define MAX_SZ 1048576 /* use no more than sizeof(double) * 1 MB */
#define BUF_SZ 1024 /* size of buffer in which we accumulate */

int 
approx_frequent_make(
  uint32_t n_input_vals_estimate,
  uint32_t err,
  uint32_t min_freq,
  approx_frequent_state_t *ptr_state
  )
{
  int status = 0;
  cntrs_t *cntrs = NULL;
  double *buffer = NULL;
  cntrs_t *cnt_buffer = NULL;
  /* Check inputs */
  if ( n_input_vals_estimate <= 0 ) { go_BYE(-1); }
  if ( err <= 0 ) { go_BYE(-1); } 
  if ( min_freq <= 0 ) { go_BYE(-1); }
  if ( min_freq - err <= 0 ) { go_BYE(-1); }
  if ( ptr_state == NULL ) { go_BYE(-1); }

  memset(ptr_state, 0, sizeof(approx_frequent_state_t));
  double eps = (double)err/(double)n_input_vals_estimate; 
  /* parameter of FREQUENT algorithm, decides the error in approximation */
  if ( eps < pow(2,-50) ) { go_BYE(-2); } /* need too much memory */
#ifdef XXX
  if ( out_siz < n_input_vals_estimate/(min_freq - err) ) { go_BYE(-3); }
    /* insufficient memory allocated to the outputs y and f */
  //-----------------------------------------------------------------
#endif
  /* The algorithm will be using n_cntrs = (1/eps)+1 counters: 
   * These are stored in cntrs which is a struct of (cntr_id, cntr_freq) */

  uint32_t n_cntrs = (uint32_t ) (1/eps)+1;
  if ( ( n_cntrs*(1+2+6) ) > MAX_SZ ) { go_BYE(-4); }
 /* Quitting if too much memory needed. Retry by doing one of the following:
    (i) Increase MAX_SZ if you think you have more RAM
    (ii) Increase eps (the approximation percentage) so that 
    computations can be done within RAM
     */
  cntrs = malloc(n_cntrs * sizeof(cntrs_t));
  return_if_malloc_failed(cntrs);
  memset(cntrs, 0,  n_cntrs * sizeof(cntrs_t));
  
  buffer = malloc(BUF_SZ * sizeof(double));
  return_if_malloc_failed(buffer);
  memset(buffer, 0,  BUF_SZ * sizeof(double));
  
  cnt_buffer = malloc(BUF_SZ * sizeof(cntrs_t));
  return_if_malloc_failed(cnt_buffer);
  memset(cnt_buffer, 0,  BUF_SZ * sizeof(cntrs_t));
  
  ptr_state->cntrs = cntrs;
  ptr_state->n_cntrs = n_cntrs;
  ptr_state->n_active_cntrs = 0; /* num counters with non-zero frequencies */
  ptr_state->err = err;
  ptr_state->min_freq = min_freq;
  ptr_state->n_input_vals_estimate = n_input_vals_estimate;

  ptr_state->n_buffer  = 0;
  ptr_state->sz_buffer = BUF_SZ;
  ptr_state->buffer    = buffer;

  ptr_state->n_cnt_buffer  = 0;
  ptr_state->cnt_buffer    = cnt_buffer;


  ptr_state->is_final = false;
  ptr_state->n_input_vals = 0;
BYE:
  return status;
}
static int approx_frequent_exec(
    approx_frequent_state_t *ptr_state
)
{
  int status = 0;
  //---------------------------------------------------------------------

  double *buffer = ptr_state->buffer;
  uint32_t n_buffer = ptr_state->n_buffer;
  cntrs_t *cnt_buffer = ptr_state->cnt_buffer;
  uint32_t sz_buffer = ptr_state->sz_buffer;

  qsort_asc_F8(buffer, n_buffer);
  status = sorted_array_to_id_freq(buffer, n_buffer, 
      cnt_buffer, sz_buffer, &(ptr_state->n_cnt_buffer));
  cBYE(status);

  status = update_counter(cntr_id,cntr_freq,cntr_siz,&n_active_cntrs,bf_id,bf_freq,bf_siz);
  cBYE(status);
BYE:
  return status;
}
//-----------------------------------------------
int 
approx_frequent_add(
    approx_frequent_state_t *ptr_state,
    double val
    )
{
  int status = 0;
  if ( ptr_state->is_final) { go_BYE(-1); }
  ptr_state->n_input_vals++;
  if ( ptr_state->n_buffer < ptr_state->sz_buffer ) {
    ptr_state->buffer[ptr_state->n_buffer] = val;
    ptr_state->n_buffer++;
  }
  if ( ptr_state->n_buffer < ptr_state->sz_buffer ) { return status; }
  status = approx_frequent_exec(ptr_state); cBYE(status);
BYE:
  return status;
}
int 
approx_frequent_final(
    approx_frequent_state_t *ptr_state
    )
{
  int status = 0;
  /* Post-processing, writing the outputs */

  long long jj = 0;
  for ( long long ii = 0; ii < n_active_cntrs; ii++ ) {

    if ( cntr_freq[ii] >= (min_freq-err) ) {
      y[jj] = cntr_id[ii]; f[jj] = cntr_freq[ii];
      jj++;
    }

  }

  *ptr_len = jj;
  *ptr_estimate_is_good = 1;

BYE:
  return status;
}

void
approx_frequent_free(
    approx_frequent_state_t *ptr_state
    )
{
  free_if_non_null(ptr_state->buffer);
  free_if_non_null(ptr_state->cnt_buffer);
  free_if_non_null(ptr_state->cntrs);
  free_if_non_null(ptr_state->high_rollers);
}
//-----------------------------------------------------------------------
/* README: 

status = approx_frequent(x,siz,min_freq,err,y,f,out_siz,ptr_len,ptr_estimate_is_good) : The algorithm takes as input an array of integers, and lists out the "frequent" elements in the set approximately, where "frequent" elements are defined as elements occuring greater than or equal to "min_freq" number of times in the input. The approximated output has the following properties: 

(1) all elements in x occuring greater than or equal to min_freq number of times  will definitely be listed in y (THESE ARE THE FREQUENT ELEMENTS (definition) )
(2) their corresponding frequency in f will be greater than or equal to (min_freq-err), i.e., the maximum error in estimating their frequencies is err.
(3) no elements in x occuring less than (min_freq-err) number of times will be listed in y

The approximation is two fold: 
(i) the estimated frequencies of the "frequent" elements can be off by a maximum of err.
(ii) elements occuring between (min_freq-err) and (min_freq) number of times can also be listed in y.


For example: say min_freq = 500 and err = 100.  y will contain the id of all the elements occuring >= 500 definitely, and their corresponding estimated frequency in f would definitely be >= (500-100) = 400. No element in x which occurs less than 400 times will occur in y. Note that elements with frequency between 400 and 500 "can" be listed in y.

Author: Kishore Jaganathan

Algorithm: FREQUENT algorithm (refer to Cormode's paper "Finding Frequent Items in Data Streams")

NOTE: This implementation is a slight variant of the algorithm mentioned in the paper, so that some steps can be parallelized. 

INPUTS: 

x: The input array 

cfld: two options - (1) NULL: All elements of x are processed.
(2) non-NULL: Array of same size as x. Acts as a select vector (only those elements with non-zero values in cfld are processed). ex: If x has 10 elements and cfld is {0,0,1,0,0,0,1,0,1,0}, then only the 3rd, 7th and 9th element are chosen for processing.

siz: Number of elements in the input array x

min_freq: elements occuring greater than or equal to min_freq times in x (among the ones selected for processing) are considered frequent elements. All of their id's will definitely be stored in y.

err: the measured frequencies of the "frequent" elements in x (i.e., occuring >= min_freq times in x, among the ones selected for processing) will definitely be greater than or equal to min_freq-err, and will be stored in f (corresponding to the id stored in y). Also, no element with frequency lesser than (min_freq-err) in x (among the ones selected for processing) will occur in y. Note: Lesser the error, more memory is needed for computation

out_siz: number of integers that can be written in y and f (prealloced memory). See y and f for how much to allocate.


OUTPUTS:

y: array containing the id's of the "frequent" elements. Need to malloc beforehand by atleast (number of elements to be processed)/(min_freq-err) * sizeof(int). If cfld is NULL, number of elements to be processed is siz, else it is equal to the number of non-zero entries in cfld.

f: array containing the corresponding frequencies of the "frequent" elements. Need to malloc beforehand by atleast (number of elements to be processed)/(min_freq-err) * sizeof(int). If cfld is NULL, number of elements to be processed is siz, else it is equal to the number of non-zero entries in cfld.

out_siz: number of integers that can be written in y and f (prealloced memory). See y and f for how much to allocate.

ptr_len: the size of y and f used by the algorithm to write the ids and frequencies of estimated approximate "frequent" elements

ptr_estimate_is_good: pointer to a location which stores 1, -1, -2 or -3
1: approximate calculations were successful, results stored in y,f and ptr_len
-1: something wrong with the input data. Check if sufficient malloc was done beforehand to y and f, in case you forgot.
-2: need too much memory, hence didn't do the calculations. Can retry with one of the following two things : (i) increase MAX_SZ if you are sure you have more RAM available (ii) increase err (the approximation parameter). Increasing err will result in more approximation (hence answer being less accurate) but memory requirements will be lesser.

status: will return 0 or -1
0: two cases - (i) calculations are successful, ptr_estimate_is_good will be set to 1 (ii) need too much memory and hence didn't do the calculations, ptr_estimate_is_good will be set to -2.
-1: Something wrong with inputs, ptr_estimate_is_good will also be set to -1

 */
//-----------------------------------------------------------------------------
