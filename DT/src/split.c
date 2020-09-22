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
    uint32_t n,
    uint32_t m,
    uint64_t **Y, /* [m][n] */
    uint64_t *tmpY /* [n] */
   )
{
  int status = 0;
  if ( ub - lb <= MIN_LEAF_SIZE ) { return status; }
#ifdef FAKE
  static 
#endif
  uint32_t split_j = -1;
  uint32_t split_i, split_val;
#ifdef DEBUG
  printf("Splitting %u to %u \n", lb, ub);
  status = check(to, g, lb, ub, n, m, Y); cBYE(status);
#endif

  //-----------------------------------------
#ifdef FAKE
  split_j++; if ( split_j == m ) { split_j = 0; }  // TODO FIX 
  split_i = lb + ((ub - lb)/2); // just for now 
#else
  status = search(lb, ub, m, Y, &split_j, &split_val,  &split_i); 
  cBYE(status); 
#endif
  //---------------------------------------------------
  for ( uint32_t j = 0; j < m; j++ ) {
    uint32_t idx, lidx = lb, ridx = split_i;
    uint64_t *Yj = Y[j];
    // TODO Uncomment this: if ( j == split_j ) { continue; }
    for ( uint32_t i = lb; i < ub; i++ ) { 
      uint32_t from_i = get_from(Y[j][i]);
      if ( from_i >= n ) { 
        go_BYE(-1); 
      }
      uint32_t to_i   = to[split_j][from_i];
      if ( to_i < split_i ) { // this data point went left
        idx = lidx; tmpY[lidx++] = Yj[i]; 
      }
      else { // this data point went right
        idx = ridx; tmpY[ridx++] = Yj[i]; 
      }
      to[j][from_i] = idx;
    }
    if ( lidx != split_i ) { go_BYE(-1); }
    if ( ridx != ub ) { go_BYE(-1); }
    if ( j == split_j ) { 
      for ( uint32_t i = lb; i < ub; i++ ) { 
        if ( Yj[i] != tmpY[i] ) { go_BYE(-1); }
      }
    }
    else {
      for ( uint32_t i = lb; i < ub; i++ ) { 
        Yj[i] = tmpY[i];
      }
    }
  }

  status = split(to, g, lb, split_i, n, m, Y, tmpY); cBYE(status);
  status = split(to, g, split_i, ub, n, m, Y, tmpY); cBYE(status);

BYE:
  return status;
}
