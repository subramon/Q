#include "q_incs.h"
#include "spooky_struct.h"
#include "spooky_hash.h"
#include "rdtsc.h"
#include "approx_unique.h"

static inline int 
determine_rho_loc(
    uint64_t hash_val,
    int m,
    int *ptr_rho,
    int *ptr_loc
    )
//--------------------------------------------------------------
/* README: 

determine_rho_loc(hash_val,m,ptr_rho,ptr_loc): This function calculates the rho and loc value for a given hash value and number of bins. rho is the location of the least significant 1 in the binary representation of hash_val. loc is the bin id to which the input element is assigned. 

INPUTS:

hash_val: 64-bit integer produced by some hash function.

m: Number of bins used by the algorithm.

OUTPUTS: 

ptr_rho: Location where the rho value is stored. ex: if hash_val = 0b1001111000100 then rho = 3, if hash_val = 0b010101111 then rho = 1.

ptr_loc: Location where the loc value is stored. If m bins are used, this value is going to be in between 0 and m-1.

 */
//----------------------------------------------------------------
{
  int status = 0;

  if ( hash_val == 0 ) { go_BYE(-1); }

  *ptr_rho = -1; 
  *ptr_loc = -1; 

  /* Last (64-20) bits of hash_val's binary representation are used to calculate rho */

  int rho = __builtin_ctzll(hash_val)+1;

  /* First 20 bits of hashval's binary representation are used to calculate loc. */

  uint32_t uint_hash_val = (uint32_t) (hash_val >> (64-20));
  int loc = (int) (uint_hash_val & (m-1));

  /* Sanity checking: A rho value of greater than (64 - 20) would imply one of the two things:
     (1) The odd chance that hash_val is divisible by 2^44. Just retrying might help unless the cardinality is higher than 1 trillion. 
     (2) more hash bits are needed to calculate rho. Use 128 bit hashfunctions (like spooky_hash128) and change this code accordingly in that case (this won't occur unless you are dealing with data sets with greater than 100 billion unique elements, which rarely happens). 

*/

  if ( rho > (64-20) ) { go_BYE(-1); }

  *ptr_rho = rho;
  *ptr_loc = loc;

BYE:
  return (status);
}

int 
approx_unique_make(
    approx_unique_state_t *ptr_state,
    int m
    )
{
  int status = 0;

  //-- make sure m is good
  if ( m <  0 ) { go_BYE(-1); }
  if ( m == 0 ) { m = 65536;      }
  if ( (m & (m-1)) != 0 || m < 128 || m > (1<<20) ) { go_BYE(-1); }

  ptr_state->m = m;
  ptr_state->max_rho = malloc(m * sizeof(int));
  return_if_malloc_failed(ptr_state->max_rho);
  memset(ptr_state->max_rho, 0, m * sizeof(int) );
  ptr_state->seed = RDTSC();

BYE:
  return status;
}

int 
approx_unique_free(
    approx_unique_state_t *ptr_state
    )
{
  int status = 0;
  if ( ptr_state->m <= 0 ) { go_BYE(-1); }
  free_if_non_null(ptr_state->max_rho);
BYE:
  return status;
}

int 
approx_unique_exec(
    approx_unique_state_t *ptr_state,
    char *x,
    int sz_x
    )
{
  int status = 0;
  //-------------------------------------------------------------
  /*
     (1) calculate hash value using spooky_hash64 (or any other hashfunction)
     (2) determine rho and loc (bin id) values using determine_rho_loc 
     (3) update max_rho accordingly 
     */

  int *max_rho = ptr_state->max_rho;
  int m        = ptr_state->m;
  int seed     = ptr_state->seed;
  uint64_t hashval = spooky_hash64(x, sz_x, seed);
  int loc = 0, rho = 0;
  status = determine_rho_loc(hashval, m, &rho, &loc); cBYE(status);
  /* TODO Think about why we had following
  if ( status == -1 ) {
    *ptr_estimate_is_good = -3;
    *ptr_accuracy = 100;
    *ptr_y = -1;
    go_BYE(0);
  }
  */
  if ( max_rho[loc] < rho ) { 
    max_rho[loc] = rho;
  }

BYE:
  return status;
}

int 
approx_unique_final(
    approx_unique_state_t *ptr_state,
    int *ptr_estimate,
    double *ptr_accuracy,
    int *ptr_estimate_is_good 
    )
{
  int status = 0;
  int *max_rho = ptr_state->max_rho;
  int m        = ptr_state->m;

  /* Check inputs */
  if ( ptr_estimate == NULL ) { go_BYE(-1); }
  if ( ptr_accuracy == NULL ) { go_BYE(-1); }
  if ( ptr_estimate_is_good == NULL ) { go_BYE(-1); }
  *ptr_estimate = -1;
  *ptr_accuracy = 100;
  *ptr_estimate_is_good = -1; /* default */


  /* If some max_rho's are zero, it means that all bins were not used sufficiently and hence stochastic averaging (law of large numbers, assumed by hyperloglog) was not done properly (due to using too many bins for too few data). In such a situation, bins will be merged here. */

  /* Bin merging rule (change only if you know what you are doing):
     While ( 1% of the bins were not used by any element ) {
     Combine every adjacent bin: for ex - if m was 65536, bins {0,1} {2,3} {4,5}... {65534,65535} will be merged to get 32768 bins. max_rho of the new bins can be easily calculated by choosing the maximum of the two corresponding bins. 
     } */

  /* If m becomes less than 128, it would mean that the algorithm failed to estimate the cardinality within 30% accuracy {3 * 1.04/sqrt(m) - 3 sigma rule}. This would be due to input cardinality being too less, in which case I would recommend (key, count) based sorting using binary search trees due to low cardinality. The algorithm would quit setting *y to -1, *ptr_estimate_is_good to 0 and *ptr_estimate_accuracy to 100 %. */


  int cnt_zero = 0;
  for ( int ii = 0; ii < m; ii++ ) { 
    if ( max_rho[ii] == 0 ) { cnt_zero++; }
  }

  while ( cnt_zero > m/100 && m > 128) {

    int jj = 0;
    for ( int ii = 0; ii < m; ii+=2) {
      if ( max_rho[ii] >= max_rho[ii+1] ) {
        max_rho[jj++] = max_rho[ii];
      }
      else {
        max_rho[jj++] = max_rho[ii+1];
      }
    }
    m = jj; 

    cnt_zero = 0;
    for ( int ii = 0; ii < m; ii++ ) { 
      if ( max_rho[ii] == 0 ) { cnt_zero++; }
    }

  }
  if ( cnt_zero < m/100 ) {
    *ptr_estimate_is_good = 1;
    *ptr_accuracy = (double)1.04/sqrt(m)*3*100;

    double temp_val = 0;   
    for ( int ii = 0; ii < m; ii++ ) {
      temp_val = temp_val + pow(2,-(double)max_rho[ii]);
    }
    temp_val = 1/temp_val;
    double alpha_m = 0.7213/(1+1.079/m); /* true for m >= 128 */
    *ptr_estimate = (int)(alpha_m*pow(m,2)*temp_val);

  }
  else {
    *ptr_estimate_is_good = -2; 
    *ptr_accuracy = 100;
    *ptr_estimate = -1;
    go_BYE(0);
    /* algorithm failed to estimate cardinality within 30% accuracy */
  }
BYE:
  return (status);
}
//----------------------------------------------------------------------------
/* README: 

status = approx_unique(x,ptr_estimate,ptr_accuracy,ptr_estimate_is_good): Calculates the cardinality (number of unique elements) of an integer set approximately using very little memory. The percentage accuracy in estimation (the approximation basically) will be stored in ptr_accuracy. 

The approximation percentages observed during extensive testing are roughly as follows:
(i) Data sets with cardinality  > 200,000 will be estimated within 1% accuracy
(ii) Data sets with cardinality > 100,000 will be estimated with 2-3% accuracy
(iii) Data sets with cardinality > 10,000 will be estimated with 6% accuracy
(iv) Data sets with cardinality > 1,000 will be estimated with 30% accuracy
(v) Data sets with cardinality < 1,000: the algorithm will quit setting ptr_accuracy to 100 and ptr_estimate_is_good will have a value -2.

Author: Kishore Jaganathan

Algorithm: Hyperloglog by Philippe Flajolet 

INPUTS: 

x: array containing the input data to be processed.

nX: Number of elements in the input array x. 

OUTPUTS: 

ptr_y: Pointer to the location where the calculated cardinality of x will be stored.

ptr_accuracy: Pointer to the location where the percentage error in the calculated cardinality of x will be stored. ex: 1.22 => +/-1.22% (3 sigma rule used)

ptr_estimate_is_good: Pointer to a location where 1,-1,-2 or -3  will be stored. Use this as a sanity check: 1 is good, everything else is bad.
(1) 1: Hyperloglog algorithm successfully calculated cardinality. Outputs *y, *ptr_estimate_accuracy are reliable/ accurate with very high probability (99%). 
(2) -1: Hyperloglog algorithm failed to calculate the cardinality due to error in inputs (some of them NULL maybe). *y will be set to -1 and *ptr_accuracy will be set to 100%. 
(3) -2: Hyperloglog algorithm failed to calculate cardinality as input cardinality too small for Hyperloglog to work. I would suggest using (key, value) storage based sorting using binary search trees (example: std::maps in C++, levelDB etc) due to low cardinality. *y will be set to -1 and *ptr_accuracy will be set to 100%
(4) -3: Hyperloglog algorithm failed to calculate cardinality due to one of the two cases: (a) The odd chance that the hash function produced a value which is divisible by 2^44. This will happen very very very rarely unless you are dealing with datasets with more than 100 billion unique elements, just retrying the code would help solve the issue. (b) The dataset indeed has more than 100 billion unique elements. In that case, you need to use a 128 bit hash function (like "spooky_hash128"). Edit this code and determine_rho_loc code accordingly. Make sure you back up this code before editing. *y will be set to -1 and *ptr_accuracy will be set to 100%.

status: Takes values 0 or -1. 
0: The algorithm either computed the cardinality and set  *ptr_estimate_is_good to 1 (and ptr_accuracy to whatever % the accuracy is) or the computations were not possible and set *ptr_estimate_is_good to -2 (low cardinality) or -3 (extremely high cardinality or hash function gave bad outputs). 
-1: Something wrong with the inputs, *ptr_estimate_is_good will be set to -1.

*/
//------------------------------------------------------------------
  /* m is the number of bins used by hyperloglog. Calculations in this work assume m to be power of 2 and 128 <= m <= 2^20 for convenience. Unless you know what you are doing and it's impact on other lines of this code (incl. determine_rho_loc function), PLEASE DONOT VIOLATE THIS CONDITION.*/

  /* NOTE: Higher m guarantees lesser error (less than {3 * 1.04/sqrt(m)} % with 99% probability). This would mean that m = Inf would give us 0 error. The catch is that hyperloglog algorithm assumes that all bins are used by atleast some input elements (to ensure stochastic averaging). Typical thumb rule for  m: the cardinality of the data set has to be atleast around 3-5 times m (ideally m log(m) so that all the bins are used sufficiently). This can't be checked beforehand as we don't know the cardinality (that's what we are trying to estimate here). The strategy we'll be using to overcome this: Start with a high m (65536 works well: +/- 1.22%). If some bins are unused, keep reducing m by a factor of 2 by combining neigbhoring bins (to maintain independence) till all the bins are used sufficiently. */

