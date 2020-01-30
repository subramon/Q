#include <stdio.h>
#include "../gen_inc/_is_next_lt_I4.h"
#include "../gen_inc/_is_next_gt_I4.h"

int main(
  int argc,
  char **argv
)
{
  int status = 0;
#define NUM_BLKS 10
#define BLK_SIZE 10
  int n = NUM_BLKS * BLK_SIZE;
  int32_t X[n];
  for ( int i = 0; i < n; i++ ) { X[i] = i*10+1; }

  //--------------------------------------
  is_next_gt_I4_ARGS gt_args;
  gt_args.num_seen = 0;
  gt_args.prev_val = 0;
  gt_args.is_violation = 0;
  int chk_num_seen = 0;
  for ( int i = 0; i < NUM_BLKS; i++ ) { 
    uint64_t idx = i * BLK_SIZE;
    int32_t *Y = &(X[idx]);
    status = is_next_gt_I4(Y, BLK_SIZE, &gt_args, idx);
    chk_num_seen += BLK_SIZE;
    if ( gt_args.num_seen != chk_num_seen ) { go_BYE(-1); }
    if ( gt_args.is_violation != 0 ) { go_BYE(-1); }
    if ( gt_args.is_violation == 1 ) { break; }
  }
  if ( gt_args.num_seen != n ) { go_BYE(-1); }
  //--------------------------------------
  is_next_lt_I4_ARGS lt_args;
  lt_args.num_seen = 0;
  lt_args.prev_val = 0;
  lt_args.is_violation = 0;
  chk_num_seen = 0;
  for ( int i = 0; i < NUM_BLKS; i++ ) { 
    uint64_t idx = i * BLK_SIZE;
    int32_t *Y = &(X[idx]);
    status = is_next_lt_I4(Y, BLK_SIZE, &lt_args, idx);
    chk_num_seen += BLK_SIZE;
    if ( lt_args.num_seen != 1 ) { go_BYE(-1); }
    if ( lt_args.is_violation != 1 ) { go_BYE(-1); }
    break;
  }
  //--------------------------------------
BYE:
  if ( status < 0 ) { 
    fprintf(stderr, "%s:FAILURE\n", argv[0]);
  }
  else {
    fprintf(stderr, "%s:SUCCESS\n", argv[0]);
  }
  return status;
}
