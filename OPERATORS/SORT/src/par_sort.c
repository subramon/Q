// gcc -O4 par_sort.c qsort_asc_I4.c -fopenmp -I../../../UTILS/inc/ -lgomp
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>
#include "qsort_asc_I4.h"
#include "q_incs.h"


#define __DATA_TYPE__ uint32_t
#define SHIFT_TO_TRUNCATE 16

static uint64_t RDTSC( void)
{
  unsigned int lo, hi;
  asm volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
}

static inline int
get_bidx(
      uint16_t val, 
      uint16_t *trunc_lb, 
      uint16_t *trunc_ub, 
      int num_bins
      )
{
  int bidx = 0;
#pragma omp simd reduction(+:bidx)
  for ( int b = 0; b < num_bins; b++ ) {
    uint8_t x = ( ( val >= trunc_lb[b] ) && ( val < trunc_ub[b] ));;
    uint16_t mask = x ? 0xFFFFFFFF : 0;
    bidx = bidx + ( mask & b );
  }
  return bidx;
}

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  // config parameters
  uint64_t n = 512 * 1048576;
  int num_bins = 4;
  //-- allocations needed for following
  __DATA_TYPE__ **lX = NULL;
  __DATA_TYPE__ *ub = NULL;
  uint16_t *trunc_ub = NULL;
  uint16_t *trunc_lb = NULL;
  uint64_t *num_in_bin = NULL;
  uint64_t *cum_num_in_bin = NULL;
  __DATA_TYPE__ *X = NULL;
  // other variables
  uint64_t t_start, t_stop; // malloc and initialize data 
  X = malloc(n * sizeof(__DATA_TYPE__));
  return_if_malloc_failed(X);
  for ( int i = 0; i < n; i++ ) { X[i] = rand(); }
  //---------------------------------
  // Allocate space for each bin
  int bin_size = (int)((float)n / (float)num_bins  * 1.1);

  lX = malloc(num_bins * sizeof(__DATA_TYPE__ *));
  return_if_malloc_failed(lX);
  for ( int b = 0; b < num_bins; b++ ) { lX[b] = NULL; }

  num_in_bin = malloc(num_bins * sizeof(uint64_t));
  return_if_malloc_failed(num_in_bin);

  cum_num_in_bin = malloc(num_bins * sizeof(uint64_t));
  return_if_malloc_failed(cum_num_in_bin);

  ub = malloc(num_bins * sizeof(uint64_t));
  return_if_malloc_failed(ub);

  trunc_ub = malloc(num_bins * sizeof(uint16_t));
  return_if_malloc_failed(trunc_ub);

  trunc_lb = malloc(num_bins * sizeof(uint16_t));
  return_if_malloc_failed(trunc_lb);

  for ( int b = 0; b < num_bins; b++ ) { 
    num_in_bin[b] = 0;
    lX[b] = malloc(bin_size * sizeof(int32_t));
    return_if_malloc_failed(lX[b]);
  }
  // START: This is a hack to estimate quantiles
  for ( int b = 0; b < num_bins; b++ ) { 
    ub[b] = (uint64_t)((float)(RAND_MAX) / (float)num_bins * (b+1));
    trunc_ub[b] = ub[b] >> SHIFT_TO_TRUNCATE;
  }
  ub[num_bins-1] = INT_MAX;
  trunc_ub[num_bins-1] = USHRT_MAX;

  trunc_lb[0] = 0;
  for ( int b = 1; b < num_bins; b++ ) { 
    trunc_lb[b] = trunc_ub[b-1];
  }

  // STOP : This is a hack to estimate quantiles
  // Copy each element from input into its correct bin
  t_start = RDTSC();
  for ( uint64_t i = 0; i < n; i++ ) { 
    __DATA_TYPE__ val = X[i];
    val = val >> SHIFT_TO_TRUNCATE;

    int bidx = 0;
    for ( int b = 0; b < num_bins; b++ ) {
      if ( val < trunc_ub[b] ) { bidx = b; break; }
    }
    int chk_bidx = bidx;

    /*
     * int bidx = get_bidx(val, trunc_lb, trunc_ub, num_bins);
    if ( bidx != chk_bidx ) { 
      printf("hello world\n"); go_BYE(-1); 
    }
    */
    uint64_t where_to_put = num_in_bin[bidx];
    // printf("Placing %d in %d of %d \n", i, where_to_put, bidx);
    lX[bidx][where_to_put] = val;
    num_in_bin[bidx] = where_to_put + 1;
  }
  t_stop = RDTSC();
  uint64_t pre_move_time = t_stop - t_start;
  printf("pre_move time  = %" PRIu64 "\n", pre_move_time);
  t_start = RDTSC();
#pragma omp parallel for 
  for ( int b = 0; b < num_bins; b++ ) {
    qsort_asc_I4 (lX[b], num_in_bin[b]);
  }
  t_stop = RDTSC();
  uint64_t psort_time = t_stop - t_start;
  printf("psort time = %" PRIu64 "\n", psort_time);
  // Copy everything back to original location
  // convert num_in_bin to cumulative count
  cum_num_in_bin[0] = 0;
  for ( int b = 1; b < num_bins; b++ ) { 
    cum_num_in_bin[b] = cum_num_in_bin[b-1] + num_in_bin[b-1];
  }
  t_start = RDTSC();
// #pragma omp parallel for 
  for ( int b = 0; b < num_bins; b++ ) {
    __DATA_TYPE__ *addr = X + cum_num_in_bin[b];
    memcpy(addr, lX[b], sizeof(__DATA_TYPE__) * num_in_bin[b]);
  }
  t_stop = RDTSC();
  uint64_t post_move_time = t_stop - t_start;
  printf(" post_move time = %" PRIu64 "\n", post_move_time); 
  // put some random numbers and do sequential sort
#pragma omp parallel for schedule(static)
  for ( int i = 0; i < n; i++ ) { X[i] = rand(); }

  t_start = RDTSC();
  qsort_asc_I4 (X, n);
  t_stop = RDTSC();
  uint64_t seq_time = t_stop - t_start;
  printf(" seq  time = %" PRIu64 "\n", seq_time);
  printf("         n = %" PRIu64 "\n", n);
  printf("speed up   = %lf\n", 
      (double)seq_time / 
      (double)(pre_move_time + post_move_time+ psort_time));

BYE:
  free_if_non_null(X);
  if ( lX != NULL ) { 
    for ( int b = 0; b < num_bins; b++ ) { 
      free_if_non_null(lX[b]);
    }
  }
    free_if_non_null(lX);

  free_if_non_null(num_in_bin);
  free_if_non_null(ub);
  free_if_non_null(trunc_ub);
  free_if_non_null(trunc_lb);
  free_if_non_null(cum_num_in_bin);
}
