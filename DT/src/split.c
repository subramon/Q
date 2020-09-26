#include "incs.h"
#include "check.h"
#include "preproc_j.h"
#include "reorder.h"
#include "search.h"
#include "split.h"

int 
split(
    uint32_t **to, /* [m][n] */
    uint8_t *g, // for debugging 
    uint32_t lb,
    uint32_t ub,
    uint32_t nT, // number of tails in this data set 
    uint32_t nH, // number of heads in this data set 
    uint32_t n,
    uint32_t m,
    uint64_t **Y, /* [m][n] */
    uint64_t **tmpY /* [n] */
   )
{
  int status = 0;
  four_nums_t num4; memset(&num4, 0, sizeof(four_nums_t));
  if ( ub - lb <= MIN_LEAF_SIZE ) { return status; }
#ifdef FAKE
  static 
#endif
  uint32_t split_j = -1;
  uint32_t split_yidx, split_yval;
#ifdef VERBOSE
  printf("Splitting %u to %u \n", lb, ub);
#endif
#ifdef DEBUG
  status = check(to, g, lb, ub, nT, nH, n, m, Y); cBYE(status);
#endif

  //-----------------------------------------
#ifdef FAKE
  split_j++; if ( split_j == m ) { split_j = 0; }
  split_yidx = lb + ((ub - lb)/2); // just for now 
#else
  status = search(Y, lb, ub, nT, nH, m, 
       &split_j, &split_yval,  &split_yidx, &num4); 
  cBYE(status); 
#endif
  //---------------------------------------------------
#pragma omp parallel for 
  for ( uint32_t j = 0; j < m; j++ ) {
    uint32_t lidx = lb, ridx = split_yidx;
    uint64_t *Yj = Y[j];
    uint64_t *tmpYj = tmpY[j];
#ifndef DEBUG
    if ( j == split_j ) { continue; }
#endif
    status = reorder(Y[j], tmpY[j], to[j], to[split_j], lb, ub,
        split_yidx, &lidx, &ridx);
    if ( status < 0 ) { WHEREAMI; status = -1; continue; }
    if ( lidx != split_yidx ) { WHEREAMI; status = -1; continue; }
    if ( ridx != ub ) { WHEREAMI; status = -1; continue; }
    if ( j != split_j ) { 
      // SLOW: for ( uint32_t i = lb; i < ub; i++ ) { Yj[i] = tmpYj[i]; }
      memcpy(Yj+lb, tmpYj+lb, (ub-lb) * sizeof(uint64_t)); // FAST
    }
    else { // no need to re-order feature chosen for split 
#ifdef DEBUG
      for ( uint32_t i = lb; i < ub; i++ ) { 
        if ( Yj[i] != tmpYj[i] ) { WHEREAMI; status = -1; continue; }
      }
#endif
    }
  }

  status = split(to, g, lb, split_yidx, num4.n_T_L, num4.n_H_L, n, m, Y, tmpY); cBYE(status);
  status = split(to, g, split_yidx, ub, num4.n_T_R, num4.n_H_R, n, m, Y, tmpY); cBYE(status);

BYE:
  return status;
}
