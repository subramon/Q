#include <time.h>
#include "q_incs.h"
#include "q_macros.h"

static int
srt_compare(
    const void *p1, 
    const void *p2
    )
{
  return( *((int *)p1) > *((int *)p2 ) );
}

int 
unique(
    int32_t *in_buf,  // input buffer [in_size]
    uint32_t in_start, // where in input buffer to start reading from
    uint32_t in_size, 
    int32_t *out_buf, // output buffer [out_size]
    uint32_t out_start, //where in input buffer to start writing to
    uint32_t out_size, 
    int32_t *ptr_in_stop, // how far in input buffer has been read
    int32_t *ptr_out_stop // how far in output buffer has been written
    ) 
{
  int status = 0;
  //-- basic check of input parameters
  if ( out_buf == NULL ) { go_BYE(-1); }
  if (  in_buf == NULL ) { go_BYE(-1); }
  if ( in_size == 0 ) { go_BYE(-1); }
  if ( in_start >= in_size ) { go_BYE(-1); }
  if ( out_start >= out_size ) { go_BYE(-1); }
  //----------------------------
  uint32_t in_idx  = in_start;
  uint32_t out_idx = out_start;
  

  for ( ; in_idx < in_size; in_idx++ ) { 
  }
BYE:
  return status;
}

int 
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int32_t *in_vals = NULL; 
  int32_t *out_vals = NULL;
  uint32_t n_out = 0;

  //--- Process input arguments
  if ( argc != 4 ) { go_BYE(-1); }
  uint32_t n_in = (uint32_t) atoi(argv[1]);
  int32_t lb    = atoi(argv[2]);
  int32_t ub    = atoi(argv[3]);
  if ( n_in <= 0 ) { go_BYE(-1); }
  if ( (ub - lb) <= 1 ) { go_BYE(-1); }
  // We will generate n_in values in the range [lb, ub] 
  srandom(time(NULL));

  // Allocate memory for in_vals, initialize and sort ascending
  in_vals  = malloc(n_in * sizeof("int32_t"));
  return_if_malloc_failed(in_vals);
  for ( uint32_t i = 0; i < n_in; i++ ) { 
    in_vals[i] = random() % (ub - lb + 1) + lb;
  }
  qsort(in_vals, n_in, sizeof(int32_t), srt_compare);
  // Find out how much memory you need and allocate for out_vals
  uint32_t sz_out = 1;
  int32_t val = in_vals[0];
  for ( uint32_t i = 1; i < n_in; i++ ) { 
    if ( val > in_vals[i] ) { go_BYE(-1); }
    if ( val != in_vals[i] ) {
      val = in_vals[i];
      sz_out++;
    }
  }
  out_vals = malloc(sz_out * sizeof(int32_t));
  return_if_malloc_failed(out_vals);
  // Call to uniq
  int chunk_size = 8;
  int32_t chk_sz_out;
  int32_t *in_buf = in_vals;
  uint32_t in_start = 0;
  uint32_t in_size = chunk_size;
  int32_t *out_buf = out_vals;
  uint32_t out_start = 0;
  uint32_t out_size = chunk_size;
  int32_t in_stop;
  int32_t out_stop;
  for ( int i = 0; i < 10; i++ ) { 
    status = unique( in_buf,  in_start, in_size, out_buf, 
    out_start, out_size, &in_stop, &out_stop);
    cBYE(status);
  }
BYE:
  free_if_non_null(in_vals);
  free_if_non_null(out_vals);
  return status;
}
