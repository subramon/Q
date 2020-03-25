#include "q_incs.h"
#include "approx_frequent_struct.h"
#include "sorted_array_to_id_freq.h"

int
sorted_array_to_id_freq (
    double * in_buf, // [n_in_buf]          // input 
    uint32_t n_in_buf, // input 
    cntrs_t *out_buf // [sz_out_buf]  // answers written here
    uint32_t sz_out_buf 
    uint32_t *ptr_n_out_buf // output 
    )
//--------------------------------------------------------------------------
/* README:

This function takes a sorted array as input and converts it into (id,
freq) format. For example: if the input was {1,1,1,2,4,4} the ids
would be {1,2,4} and their corresponding frequencies would be {3,1,2}
as 1 occurs 3 times, 2 occurs once and 4 occurs 2 times.

 */
//--------------------------------------------------------------------------
{

  int status = 0;
  if ( buf == NULL ) { go_BYE(-1); }
  if ( out_buf == NULL ) { go_BYE(-1); }
  uint32_t n_out_buf = 0;
  if ( n_in_buf == 0 ) { *ptr_n_out_buf = 0; return status; }

  out_buf[n_out_buf].val = in_buf[0];
  out_buf[n_out_buf].cnt = 1;
  n_out_buf++;
  for ( int i = 1; i < n_in_buf; i++ ) { 
    if ( in_buf[i] == out_buf[n_out_buf].val ) {
      out_buf[n_out_buf-1].cnt++;
    }
    else {
      out_buf[n_out_buf].val = in_buf[i];
      out_buf[n_out_buf].cnt = 1;
      n_out_buf++;
    }
  }
  *ptr_n_out_buf = n_out_buf;
BYE:
  return status;
}
