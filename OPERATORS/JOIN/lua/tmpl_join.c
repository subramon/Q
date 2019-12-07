#include "q_incs.h"
#define EXISTS 1
#define MIN 2
#define MAX 3
#define SUM 4
#define MIN_IDX 5
#define MAX_IDX 6
/*
 * Note that if join_type == EXISTS, then we don't send in dst_val.
 * We use nn_dst_val instead */
/* For join, we will assume all columns ar fully materialized */
int
join(
    uint64_t offset,
    const char *const join_type,
    int *src_val,
    uint64_t *nn_src_val,
    int *src_lnk, // cannot have a nn field 
    uint64_t nR_src,
    int *dst_val,
    uint64_t *nn_dst_val,
    int *dst_lnk, // cannot have a nn field 
    uint64_t nR_dst
    )
{
  int status = 0;
  uint64_t src_idx = 0;
  uint64_t dst_idx = 0;
  int sval = src_val[src_idx];
  int dval = dst_val[dst_idx];
  uint64_t lb = 0;
  uint64_t ub = nR_dst;
  if ( src_val == NULL ) { go_BYE(-1); }
  if ( src_lnk == NULL ) { go_BYE(-1); }
  if ( join_type == EXISTS ) { 
    if ( dst_val != NULL ) { go_BYE(-1); }
  }
  else {
    if ( dst_val == NULL ) { go_BYE(-1); }
  }
  if ( dst_lnk == NULL ) { go_BYE(-1); }
  if ( nn_dst_val == NULL ) { go_BYE(-1); }
  if ( nR_src == 0 ) { go_BYE(-1); }
  if ( nR_dst == 0 ) { go_BYE(-1); }
  if ( strcmp(join_type, "exists") == 0 ) { join_type = EXISTS; }
  else if ( strcmp(join_type, "min" == 0 ) ) { join_type = MIN; }
  else if ( strcmp(join_type, "max" == 0 ) ) { join_type = MAX; }
  else if ( strcmp(join_type, "sum" == 0 ) ) { join_type = SUM; }
  else if ( strcmp(join_type, "min_idx" == 0 ) ) { join_type = MIN_IDX; }
  else if ( strcmp(join_type, "max_idx" == 0 ) ) { join_type = MAX_IDX; }
  else { go_BYE(-1); }

  int num_threads = sysconf(_SC_NPROCESSORS_ONLN);

  uint64_t block_size = nR_dst / num_threads;
#pragma omp parallel for schedule(static)
  for ( uint32_t t = 0; t < num_threads; t++ ) { 
    uint64_t lb = t * block_size;
    uint64_t ub = lb + block_size;
    if ( t == (num_threads-1) ) { ub = nR_dst; }

    for ( uint64_t i = lb; i < ub; ) {
      bool first = true;
      dst_val[i] = 0;
      nn_dst_val[i] = 0;
      // If current value same as previous, re-use earlier result
      if ( ( i > 0 ) && ( dst_val[i] == dst_val[i-1] ) ) {
        nn_dst_val[i] = nn_dst_val[i-1];
        if ( dst_val != NULL ) { 
          dst_val[i] = dst_val[i-1];
        }
        i++;
        continue;
      }
      uint64_t j = src_idx;
      for ( ; j < nR_src; ) {
        if ( src_lnk[j] < dst_lnk[i] ) {
          j++;
        }
        else if ( src_lnk[j] == dst_lnk[i] ) {
          nn_dst_val[i] = 1;
          if ( first ) {
            if ( ( join_type == MIN_IDX ) || ( join_type == MAX_IDX ) ) {
              dst_val[i] = offset + j;
            }
            else {
              dst_val[i] = src_val[j];
            }
            first = false;
          }
          else {
            if ( join_type == MIN ) { 
              dst_val[i] = mcr_min(dst_val[i], src_val[j]);
            }
            else if ( join_type == MAX ) { 
              dst_val[i] = mcr_max(dst_val[i], src_val[j]);
            }
            else if ( join_type == SUM ) { 
              dst_val[i] = mcr_sum(dst_val[i], src_val[j]);
            }
            else if ( join_type == MAX_IDX ) {
              dst_val[i] = offset + j;
            }
          }
          j++;
        }
        else {
          i++;
        }
      }
      src_idx = j;
    }
  }
BYE:
  return status;
}
