#include "q_incs.h"
#include "qsort_asc_F8.h"
#include "approx_frequent_struct.h"
#include "approx_frequent.h"
#include "sorted_array_to_id_freq.h"
#include "update_counter.h"

#define MAX_SZ 1048576 /* use no more than sizeof(double) * 1 MB */

int 
approx_frequent_make(
  uint32_t n_estimate,
  uint32_t err,
  uint32_t min_freq,
  approx_frequent_state_t *ptr_state
  )
{
  int status = 0;
BYE:
  return status;
  /* Check inputs */
  if ( x == NULL ) { go_BYE(-1); }
  if ( n_estimate <= 0 ) { go_BYE(-1); }
  if ( err <= 0 ) { go_BYE(-1); } 
  if ( min_freq <= 0 ) { go_BYE(-1); }
  if ( min_freq - err <= 0 ) { go_BYE(-1); }

  double eps = (double)err/(double)n_estimate; 
  /* parameter of FREQUENT algorithm, decides the error in approximation */
  if ( eps < pow(2,-50) ) { go_BYE(-2); } /* need too much memory */
#ifdef XXX
  if ( out_siz < n_estimate/(min_freq - err) ) { go_BYE(-3); }
    /* insufficient memory allocated to the outputs y and f */
  //-----------------------------------------------------------------
#endif
  /* The algorithm will be using n_cntrs = (1/eps)+1 counters: 
   * These are stored in cntrs which is a struct of (cntr_id, cntr_freq) */

  cntrs_t *cntrs = NULL;
  uint32_t n_cntrs = (uint32_t ) (1/eps)+1;
  if ( ( n_cntrs*(1+2+6) ) > MAX_SZ ) { go_BYE(-4); }
 /* Quitting if too much memory needed. Retry by doing one of the following:
    (i) Increase MAX_SZ if you think you have more RAM
    (ii) Increase eps (the approximation percentage) so that 
    computations can be done within RAM
     */
  cntrs = malloc(n_cntrs * sizeof(cntr_t));
  return_if_malloc_failed(cntrs);
  memset(cntrs, 0,  n_cntrs * sizeof(cntr_t));
  

  ptr_state->cntrs = cntrs;
  ptr_state->cntrs = n_cntrs;
  ptr_state->n_active_cntrs = 0; /* num counters with non-zero frequencies */
  ptr_state->err = err;
  ptr_state->min_freq = min_freq;
  ptr_state->n_estimate = n_estimate;
BYE:
  return status;
}
  //---------------------------------------------------------------------

  /* We will look at the incoming data as packets of size cntr_siz with sorted data (this would help speed up the update process a lot, this step is not mentioned in the paper - it's my improvization). Since the sorting has to be done within each packet separately, we can parallelize this step as follows: we divide the incoming data into blocks of size  = NUM_THREADS*cntr_siz (so that NUM_THREADS threads can be generated for each block and sorted separately in parallel using cilkfor) */

  /* "inputPacket" is a 2d array of size NUM_THREADS *cntr_siz: stores and sortes packets belonging to the same block in parallel using cilkfor. */

  int ** inputPackets = NULL;
  long long * inputPacketsUsedSiz = NULL;

  flag = 2;  /* inputPackets and inputPacketsUsedSiz are defined */

  inputPackets = malloc ( NUM_THREADS * sizeof(int*) );
  return_if_malloc_failed(inputPackets); 

  inputPacketsUsedSiz = malloc ( NUM_THREADS * sizeof(long long) );
  return_if_malloc_failed(inputPacketsUsedSiz);

  for ( long long ii = 0; ii < NUM_THREADS; ii++) {
    inputPacketsUsedSiz[ii] = 0;
  }

  for ( int ii = 0; ii < NUM_THREADS; ii++ ) {
    inputPackets[ii] =  (int *) malloc( cntr_siz * sizeof(int) );
  }

  flag = 3; /* inputPackets[ii] defined for ii = 0 to NUM_THREADS-1 */

  for ( int ii = 0; ii < NUM_THREADS; ii++ ) {
    return_if_malloc_failed(inputPackets[ii]);
#ifdef IPP
    ippsZero_32s((int *)inputPackets[ii],cntr_siz);
#else
    assign_const_I4(inputPackets[ii],cntr_siz,0);
#endif
  }

  //------------------------------------------------------------------------
  
  int * bf_id = NULL;
  int * bf_freq = NULL; /* temporary counters for processing */

  flag = 4;  /* bf_id and bf_freq are defined */

  bf_id = (int *)malloc( cntr_siz * sizeof(int) );
  return_if_malloc_failed(bf_id);

  bf_freq = (int *)malloc( cntr_siz * sizeof(int) );
  return_if_malloc_failed(bf_freq);

  long long current_loc_in_x = 0; /* start of input data */

  /* Do the following for each block, till you reach the end of input */
  while ( current_loc_in_x < siz ) { 

    /* A block of data ( containing NUM_THREADS packets, i.e NUM_THREADS * cntr_siz integers ) is processed inside this loop. For each packet, the following operations are done: 
     (1): Sort the packet (can be done in parallel using cilkfor)
     (2): Convert each sorted packet into (id, freq) i.e (key, count) format using sorted_array_to_id_freq(). 
     (3): Update the counter array using update_counter()
     
     Steps (1) and (2) can be done in parallel, but for some reason trying to do (2) in parallel is slowing down the code. So doing only (1) in parallel. */

    /* Copying input data into "inputPackets" buffers */

    if ( cfld == NULL || n_estimate == siz ) {

      //------------------------------------------------------------------
      for ( long long ii = 0; ii < NUM_THREADS; ii++) {
	inputPacketsUsedSiz[ii] = 0;
      }

      cilkfor ( int tid = 0; tid < NUM_THREADS; tid++ ) {

	long long lb = current_loc_in_x + tid * cntr_siz; 
	long long ub = lb + cntr_siz;
	if ( lb >= siz ) { continue; }
	if ( ub >= siz ) { ub = siz; }

	memcpy(inputPackets[tid], x+lb, (ub-lb)*sizeof(int));
	inputPacketsUsedSiz[tid] = (ub-lb);

      }

      for ( int tid = 0; tid < NUM_THREADS; tid++ ) {
	current_loc_in_x += inputPacketsUsedSiz[tid];
      }
      //------------------------------------------------------------------

    }
    else {

      //------------------------------------------------------------------
      /* NOTE: if cfld input is non-null, it means we are not interested in all the elements. In every iteration, we keep filling inputPackets buffer with only those data we are interested in using the helper variable "current_loc_in_x". */

      for ( long long ii = 0; ii < NUM_THREADS; ii++) {
	inputPacketsUsedSiz[ii] = 0;
      }
      int tid = 0;
      
      while ( current_loc_in_x < siz  && tid < NUM_THREADS ) {

	if ( cfld[current_loc_in_x] == 0 ) { current_loc_in_x++; }
	else {
	  inputPackets[tid][inputPacketsUsedSiz[tid]] = x[current_loc_in_x];
	  current_loc_in_x++; inputPacketsUsedSiz[tid]++;
	  if ( inputPacketsUsedSiz[tid] == cntr_siz ) { tid++; }
	}

      }
      //------------------------------------------------------------------

    }


    /* Step (1) can be done here in parallel using cilkfor */
    cilkfor ( int tid = 0; tid < NUM_THREADS; tid++ ) {
    
      if ( inputPacketsUsedSiz[tid] == 0 ) { continue; }

#ifdef IPP
      ippsSortAscend_32s_I(inputPackets[tid], inputPacketsUsedSiz[tid]);
#else
      qsort_asc_I4(inputPackets[tid], inputPacketsUsedSiz[tid], sizeof(int), NULL);
#endif

    }

    /* Steps (2) and (3) done here */

    for ( int tid = 0; tid < NUM_THREADS; tid++ ) {
    
      if ( inputPacketsUsedSiz[tid] == 0 ) { break; }
    
      long long bf_siz = 0;
      status = sorted_array_to_id_freq(inputPackets[tid],inputPacketsUsedSiz[tid],bf_id,bf_freq,&bf_siz); cBYE(status);

      status = update_counter(cntr_id,cntr_freq,cntr_siz,&n_active_cntrs,bf_id,bf_freq,bf_siz);
      cBYE(status);

    }


  }

  //----------------------------------------------------------------------
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

  if ( flag >= 4 ) {
    free_if_non_null(bf_id);
    free_if_non_null(bf_freq);
  }
  if ( flag >= 3 ) {
    for ( int ii = 0; ii < NUM_THREADS; ii++ ) {
      free_if_non_null(inputPackets[ii]);
    }
  }
  if ( flag >= 2 ) {
    free_if_non_null(inputPackets);
    free_if_non_null(inputPacketsUsedSiz);
  }
  if ( flag >= 1 ) {
    free_if_non_null(cntr_id);
    free_if_non_null(cntr_freq);
  }

  return(status);
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
