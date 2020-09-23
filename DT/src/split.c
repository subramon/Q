#include "incs.h"
#include "preproc_j.h"
#include "check.h"
#include "split.h"
#include "search.h"

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
    uint64_t *tmpY /* [n] */
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
#ifdef DEBUG
  printf("Splitting %u to %u \n", lb, ub);
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
  for ( uint32_t j = 0; j < m; j++ ) {
    uint32_t idx, lidx = lb, ridx = split_yidx;
    uint64_t *Yj = Y[j];
#ifdef DEBUG
    if ( j == split_j ) { continue; }
#endif
    for ( uint32_t i = lb; i < ub; i++ ) { 
      uint32_t from_i = get_from(Y[j][i]);
      if ( from_i >= n ) { 
        go_BYE(-1); 
      }
      uint32_t to_i   = to[split_j][from_i];
      if ( to_i < split_yidx ) { // this data point went left
        idx = lidx; tmpY[lidx++] = Yj[i]; 
      }
      else { // this data point went right
        idx = ridx; tmpY[ridx++] = Yj[i]; 
      }
      to[j][from_i] = idx;
    }
    if ( lidx != split_yidx ) { go_BYE(-1); }
    if ( ridx != ub ) { go_BYE(-1); }
    if ( j == split_j ) { 
#ifdef DEBUG
      for ( uint32_t i = lb; i < ub; i++ ) { 
        if ( Yj[i] != tmpY[i] ) { go_BYE(-1); }
      }
#endif
    }
    else {
      for ( uint32_t i = lb; i < ub; i++ ) { 
        Yj[i] = tmpY[i];
      }
    }
  }

  status = split(to, g, lb, split_yidx, num4.n_T_L, num4.n_H_L, n, m, Y, tmpY); cBYE(status);
  status = split(to, g, split_yidx, ub, num4.n_T_R, num4.n_H_R, n, m, Y, tmpY); cBYE(status);

BYE:
  return status;
}
