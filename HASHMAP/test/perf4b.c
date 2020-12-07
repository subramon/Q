// Similar to test4b but stand alone 
// gcc test/perf4b.c -o perf
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <float.h>
#include <limits.h>
#include <string.h>
/*-------------------------------------------------------*/
#define WHEREAMI { fprintf(stderr, "Line %3d of File %s \n", __LINE__, __FILE__);  }
#define go_BYE(x) { WHEREAMI; status = x ; goto BYE; }
#define cBYE(x) { if ( (x) < 0 ) { go_BYE((x)) } }
#define fclose_if_non_null(x) { if ( (x) != NULL ) { fclose((x)); (x) = NULL; } } 
#define free_if_non_null(x) { if ( (x) != NULL ) { free((x)); (x) = NULL; } }
#define return_if_fopen_failed(fp, file_name, access_mode) { if ( fp == NULL ) { fprintf(stderr, "Unable to open file %s for %s \n", file_name, access_mode); go_BYE(-1); } }
#define return_if_malloc_failed(x) { if ( x == NULL ) { fprintf(stderr, "Unable to allocate memory\n"); go_BYE(-1); } }
/*-------------------------------------------------------*/
#include <sys/time.h>
#include <time.h>
static uint64_t get_time_usec( void)
{
  struct timeval Tps; 
  struct timezone Tpf;
  gettimeofday (&Tps, &Tpf);
  return ((uint64_t )Tps.tv_usec + 1000000* (uint64_t )Tps.tv_sec);
}
/*-------------------------------------------------------*/
typedef int   key_t;
typedef float in_val_t;

typedef struct _val_t { 
  int cnt;
  float minval;
  float maxval;
  double sumval;
} val_t;

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int N = 2048 * 2048; // number of insertions performed 
  uint32_t num_items      = 2048;
  val_t *chk_agg = NULL;
  int   *keys = NULL; int key_len = sizeof(int);
  float *vals = NULL; int val_len = sizeof(float);

  if ( argc != 1 ) { go_BYE(-1); }
  keys = malloc(N * sizeof(int));
  return_if_malloc_failed(keys);

  vals = malloc(N * sizeof(float));
  return_if_malloc_failed(vals);

  srandom(get_time_usec());
  srand48(random());
  for ( int i = 0; i < N; i++ ) { 
    keys[i] = (int)(random() % num_items);
    vals[i] = drand48(); 
  }

  chk_agg = malloc(num_items * sizeof(val_t));
  return_if_malloc_failed(chk_agg);
  memset(chk_agg, 0,  (num_items * sizeof(val_t)));
  for ( uint32_t i = 0; i < num_items;  i++ ) { 
    chk_agg[i].minval = FLT_MAX;
    chk_agg[i].maxval = -1 * FLT_MAX;
  }

  //-----------------------------
  //-- START: independent calculation of aggregation
  for ( int i = 0; i < N; i++ ) {
    int key = keys[i];
    float val = vals[i];
    if ( chk_agg[key].minval > val ) { chk_agg[key].minval = val; }
    if ( chk_agg[key].maxval < val ) { chk_agg[key].maxval = val; }
    chk_agg[key].sumval += val;
    chk_agg[key].cnt++;
  }
  //-- STOP : independent calculation of aggregation
  // TODO: HERE IS WHERE THE C++ code goes

  //-- START: Check against indepdent calculation 
  for ( uint32_t i = 0; i < num_items; i++ ) {
    key_t key_i = keys[i];
    if ( ( key_i < 0 ) || ( key_i >= num_items ) ) { go_BYE(-1); }
    // Get the values aggregated for each key 
    int    calc_cnt = 0;
    float  calc_min = 0;
    float  calc_max = 0;
    double calc_sum = 0;
    /* TODO: Uncomment this block when you are ready to test 
    if ( calc_cnt != chk_agg[key_i].cnt ) { go_BYE(-1); }
    if ( calc_min != chk_agg[key_i].minval ) { go_BYE(-1); }
    if ( calc_max != chk_agg[key_i].maxval ) { go_BYE(-1); }
    if ( calc_sum != chk_agg[key_i].sumval ) { go_BYE(-1); }
    */
  }
    //-- START: Check against indepdent calculation 
BYE:
  free_if_non_null(chk_agg);
  free_if_non_null(keys);
  free_if_non_null(vals);
  return status;
}
