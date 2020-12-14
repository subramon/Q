#include "incs.h"
#include "preproc_j.h"
#include "reorder.h"
#include "reorder_isp.h"
#include "get_time_usec.h"
#ifdef SEQUENTIAL
int g_num_swaps;
#endif
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
  
  uint32_t *to   = NULL;
  uint32_t *isp_to   = NULL;

  uint32_t *to_split = NULL;

  uint32_t n = 100; // size of buffer
  uint32_t lb = 0; uint32_t ub = n;

  g_num_swaps = 0;
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
    uint32_t pre_from_i = get_from(Y[i]);
    uint32_t pre_goal_i = get_goal(Y[i]);
    uint32_t pre_yval_i = get_yval(Y[i]);
    uint32_t post_from_i = get_from(tmpY[i]);
    uint32_t post_goal_i = get_goal(tmpY[i]);
    uint32_t post_yval_i = get_yval(tmpY[i]);
    /*
    fprintf(stdout, "%d,%d,%d||%d,%d,%d\n", 
      pre_from_i, pre_goal_i, pre_yval_i, 
      post_from_i, post_goal_i, post_yval_i);
      */
  }
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
  
  free_if_non_null(to);
  free_if_non_null(isp_to);

  free_if_non_null(to_split);
  return status;
}
