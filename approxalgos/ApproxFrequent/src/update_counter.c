#include "q_incs.h"
#include "approx_frequent_struct.h"
#include "update_counter.h"

// START FUNC DECL
int 
update_counter (
    cntrs_t *cntrs,
    uint32_t sz_cntrs,
    cntrs_t *cnt_buffer, // [sz_cntrs] 
    uint32_t n_cnt_buffer,
    cntrs_t *merged_cntrs, // [2*sz_cntrs] 
    uint32_t *ptr_n_cntrs
    )
// STOP FUNC DECL
//-------------------------------------------------------------------------
/* README:

update_counter(cntr_id,cntr_freq,cntr_siz,ptr_active_cntr_siz,bf_id,bf_freq,bf_siz) : This function updates the counter array (cntr_id, cntr_freq) by adding new id and freq data specified by (bf_id, bf_freq).

NOTE: Both (cntr_id,cntr_freq) and (bf_id,bf_freq) are assumed to be
sorted in their id's (this has to be done beforehand). Active_cntr_siz
is the total number of counters being used in the counter array by
some ids (i.e., number of distinct elements whose approximate counts
are remembered by the algorithm at this stage). bf_siz is the total
number of distinct elements (ids) in the incoming packet. A temporary
counter array (temp_cntr_id, temp_cntr_freq) of size active_cntr_siz +
bf_siz (max possible distinct elements after merging) will be used to
merge the two id arrays. If same id's exist in both the arrays, their
counts will be added.

If the size of (temp_cntr_id,temp_cntr_freq) is higher than cntr_siz
(the number of counters available to the algorithm), some elements
will be dropped (the ids with low counts) till the size becomes less
than or equal to cntr_siz. The contents will be copied to the
(cntr_id,cntr_freq) once this criterion is met.

Algorithm: FREQUENT algorithm (Cormode's paper: Finding Frequent Items
in Data Streams). A modified implementation is used to promote
parallel processing.

INPUTS: 

cntr_id: Array containing the id data currently stored by the counters.

cntr_freq: Array containing the corresponding frequency data.

cntr_siz: Total number of counters ( size of (cntr_id,cntr_freq) ) available to do the counting.

ptr_active_cntr_siz: Number of counters in the (cntr_id, cntr_freq) counter array which are currently being used by some ids (active_cntr_siz).

bf_id: Array containing the incoming id data

bf_freq: Array containing the corresponding frequency data

bf_siz: Size of the new input (bf_id, bf_freq) data

 */
//--------------------------------------------------------------------------
{
  int status = 0;
  if ( cntrs == NULL ) { go_BYE(-1); }
  if ( sz_cntrs == 0 ) {go_BYE(-1); }
  if ( cnt_buffer == NULL ) { go_BYE(-1); }
  if ( n_cnt_buffer == 0 ) { go_BYE(-1); }
  if ( merged_cntrs == NULL ) { go_BYE(-1); }

  //---------------------------------------------------------------------
  // We merge cntrs and cnt_buffer into merge_cntr so that the result
  // is sorted on the val field

  uint32_t idx1 = 0; // for cntrs
  uint32_t idx2 = 0; // for cnt_buffer
  uint32_t oidx = 0; // for merged_cntrs
  while ( ( idx1 < sz_cntrs ) && ( idx2 < n_cnt_buffer ) ) { 
    double val1 = cntrs[idx1].val;
    double val2 = cntrs[idx2].val;
    if ( val1 < val2 ) { 
      merged_cntrs[oidx] = cntrs[idx1];
      idx1++;
      oidx++;
    }
    else if ( val1 == val2 ) { 
      merged_cntrs[oidx].val   = cntrs[idx1].val;
      merged_cntrs[oidx].freq += cnt_buffer[idx1].freq;
      idx1++;
      idx2++;
      oidx++;
    }
    else {
      merged_cntrs[oidx] = cnt_buffer[idx2];
      idx2++;
      oidx++;
    }
    if ( oidx > 0 ) {
      if ( merged_cntrs[oidx].val == merged_cntrs[oidx-1].val ) { 
        merged_cntrs[oidx-1].freq += merged_cntrs[oidx].freq;
        oidx--;
      }
    }
  }
  // We expect the val field to be *strictly* increasing in the output
  for ( uint32_t i = 1; i < oidx; i++ ) { 
    if ( merged_cntrs[i].val <= merged_cntrs[i-1].val ) { go_BYE(-1); }
    if ( merged_cntrs[i].freq == 0 ) { go_BYE(-1); }
  }

  //------------------------------------------------------------------------

  /* If the size of (temp_cntr_id,temp_cntr_freq) is less than
     cntr_siz (i.e., teh total number of counters available for use)
     then we just copy the data to (cntr_id, cntr_freq)
     (overwriting). Else, keep dropping elements with low frequencies
     (according to FREQUENT algorithm's rules so that theoretical
     guarantees hold)till the size of (temp_cntr_id,temp_cntr_freq)
     becomes less than cntr_siz and then copy the data to (cntr_id,
     cntr_freq). */


  while ( oidx > sz_cntrs ) { 

    for ( long long kk = 0; kk < *ptr_active_cntr_siz; kk++ ) {
      temp_cntr_freq[kk]--;
    }

    jj = 0;
    for ( long long kk = 0; kk < *ptr_active_cntr_siz; kk++ ) {
      if ( temp_cntr_freq[kk] > 0 ) {
        temp_cntr_freq[jj] = temp_cntr_freq[kk];
        temp_cntr_id[jj++] = temp_cntr_id[kk];
      }
    } 
    *ptr_active_cntr_siz = jj;

  }
  memcpy(cntrs, merged_cntrs, oidx*sizeof(cntrs_t));
  *ptr_n_cntrs = oidx;
BYE:
  return(status);
}
