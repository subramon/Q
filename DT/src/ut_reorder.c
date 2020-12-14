#include "incs.h"
#include "preproc_j.h"
#include "check.h"
#include "reorder.h"
#include "reorder_isp.h"
#include "get_time_usec.h"
#ifdef SEQUENTIAL
int g_num_swaps;
#endif
config_t g_C;
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  uint64_t *Y    = NULL;
  uint64_t *tmpY = NULL;
  uint64_t *isp_tmpY = NULL;

  uint32_t *yval = NULL;
  uint8_t  *goal = NULL;
  uint32_t *from = NULL;
  
  uint32_t *pre_yval = NULL;
  uint8_t  *pre_goal = NULL;
  uint32_t *pre_from = NULL;
  
  uint32_t *post_yval = NULL;
  uint8_t  *post_goal = NULL;
  uint32_t *post_from = NULL;
  
  uint32_t *to   = NULL;
  uint32_t *isp_to   = NULL;

  uint32_t *to_split = NULL;

  uint32_t n = 100; // size of buffer
  uint32_t lb = 0; uint32_t ub = n;

#ifdef SEQUENTIAL
  g_num_swaps = 0;
#endif
  if ( argc >= 2 ) { 
    n = atoi(argv[1]);
  }
  if ( n <= 0 ) { go_BYE(-1); } 
  //-----------------------------------------
  Y    = malloc(n * sizeof(uint64_t));
  tmpY = malloc(n * sizeof(uint64_t));
  isp_tmpY = malloc(n * sizeof(uint64_t));

  yval = malloc(n * sizeof(uint32_t));
  from = malloc(n * sizeof(uint32_t));
  goal = malloc(n * sizeof(uint8_t));

  pre_yval = malloc(n * sizeof(uint32_t));
  pre_from = malloc(n * sizeof(uint32_t));
  pre_goal = malloc(n * sizeof(uint8_t));

  post_yval = malloc(n * sizeof(uint32_t));
  post_from = malloc(n * sizeof(uint32_t));
  post_goal = malloc(n * sizeof(uint8_t));

  to   = malloc(n * sizeof(uint32_t));
  isp_to   = malloc(n * sizeof(uint32_t));

  to_split   = malloc(n * sizeof(uint32_t));
  // Initialization
  for ( uint32_t i = 0; i < n; i++ ) { yval[i] = i+1; }
  for ( uint32_t i = 0; i < n; i++ ) { from[i] = (n-1) - i; }
  for ( uint32_t i = 0; i < n; i++ ) { goal[i] = i % 2 ; } 
  for ( uint32_t i = 0; i < n; i++ ) { 
    Y[i] = x_mk_comp_val(from[i], goal[i], yval[i]); 
  }
  for ( uint32_t i = 0; i < n; i++ ) { tmpY[i] = 0; }
  // We decree that half the points go left, and other half go right
  uint32_t lidx = 0;
  uint32_t ridx = n / 2;
  uint32_t split_yidx = n / 2;
  uint32_t p1 = 0, p2 = n - 1;
  for ( uint32_t i = 0; i < n; ) { 
    to_split[i++] = p1++;
    to_split[i++] = p2--;
  }
  //-----------------------------------------
  status = reorder(Y, tmpY, to, to_split, lb, ub, split_yidx, &lidx, &ridx);
  cBYE(status);
  for ( uint32_t i = 0; i < n; i++ ) { 
    pre_from[i] = get_from(Y[i]);
    pre_goal[i] = get_goal(Y[i]);
    pre_yval[i] = get_yval(Y[i]);
    post_from[i] = get_from(tmpY[i]);
    post_goal[i] = get_goal(tmpY[i]);
    post_yval[i] = get_yval(tmpY[i]);
    /*
    fprintf(stdout, "%d,%d,%d||%d,%d,%d\n", 
      pre_from[i], pre_goal[i], pre_yval[i], 
      post_from[i], post_goal[i], post_yval[i]);
      */
  }
  bool is_eq;
  status = chk_set_equality(pre_from, post_from, n, &is_eq); cBYE(status);
  if ( !is_eq ) { go_BYE(-1); }
  status = chk_set_equality(pre_yval, post_yval, n, &is_eq); cBYE(status);
  if ( !is_eq ) { go_BYE(-1); }
  int cnt1 = 0, cnt2 = 0;
  for ( uint32_t i = 0; i < n; i++ ) { 
    cnt1 += pre_goal[i];
    cnt2 += pre_goal[i];
  }
  if ( cnt1 != cnt2 ) { go_BYE(-1); }
  if ( lidx != n / 2 ) { go_BYE(-1); }
  if ( ridx != n     ) { go_BYE(-1); }
  //--- run ISP version
  lidx = 0;
  ridx = n / 2;
  reorder_isp(Y, isp_tmpY, isp_to, to_split, lb, ub, split_yidx, 
      &lidx, &ridx, &status);
  cBYE(status);
  // --- compare ISP results with C results 
  if ( lidx != n / 2 ) { go_BYE(-1); }
  if ( ridx != n     ) { go_BYE(-1); }
  for ( uint32_t i = 0; i < n; i++ ) { 
    if ( tmpY[i] != isp_tmpY[i] ) { go_BYE(-1); }
    // if ( to[i] != isp_to[i] ) { go_BYE(-1); }
  }
  fprintf(stderr, "Completed test [%s] successfully\n", argv[0]);
BYE:
  free_if_non_null(Y);
  free_if_non_null(tmpY);
  free_if_non_null(isp_tmpY);

  free_if_non_null(yval);
  free_if_non_null(goal);
  free_if_non_null(from);
  
  free_if_non_null(pre_yval);
  free_if_non_null(pre_goal);
  free_if_non_null(pre_from);
  
  free_if_non_null(post_yval);
  free_if_non_null(post_goal);
  free_if_non_null(post_from);
  
  free_if_non_null(to);
  free_if_non_null(isp_to);

  free_if_non_null(to_split);
  return status;
}
