#include "incs.h"
#include "preproc_j.h"
#include "split.h"

static int 
set_equal(
    uint32_t *X,
    uint32_t *Y,
    uint32_t lb,
    uint32_t ub,
    uint32_t n,
    bool *ptr_is_eq
    )
{
  int status = 0;
  // make this n log n instead of n^2
  for ( uint32_t i = lb; i < ub; i++ ) {
    uint32_t x_i = X[i];
    bool found = false;
    for ( uint32_t j = lb; j < ub; j++ ) {
      if ( Y[j] == x_i ) { found = true; break; }
    }
    if ( !found ) { *ptr_is_eq = false; return status; }
  }
  *ptr_is_eq = true;
BYE:
  return status;
}




int 
split(
    uint32_t **to, /* [m][n] */
    uint32_t lb,
    uint32_t ub,
    uint32_t n,
    uint32_t m,
    uint64_t **Y, /* [m][n] */
    uint64_t *tmpY /* [n] */
   )
{
  int status = 0;
  bool *pos_seen = NULL;
  uint32_t *tos = NULL;
  static uint32_t split_j = 0;
  if ( ub - lb <= MIN_LEAF_SIZE ) { return status; }
  pos_seen = malloc(n * sizeof(bool));

  // some checking 
  for ( uint32_t j = 1; j < m; j++ ) {
    bool is_eq = false;
    status = set_equal(to[j-1], to[j], lb, ub, n, &is_eq); cBYE(status);
    if ( !is_eq ) { go_BYE(-1);
    }
  }
  // TODO repeat above check for froms
  
  for ( uint32_t j = 0; j < m; j++ ) {
    for ( uint32_t i = lb+1; i < ub; i++ ) { 
      uint32_t yval_i_1 = get_yval(Y[j][i-1]);
      uint32_t yval_i_2 = get_yval(Y[j][i]);
      if ( yval_i_1 > yval_i_2 ) { go_BYE(-1);
      }
    }
    for ( uint32_t i = lb; i < ub; i++ ) { pos_seen[i] = false; }
    for ( uint32_t i = lb; i < ub; i++ ) { 
      uint32_t from_i = get_from(Y[j][i]);
      pos_seen[from_i] = true;
    }
    for ( uint32_t i = lb; i < ub; i++ ) { 
      if ( !pos_seen[i] ) { go_BYE(-1); }
    }
    for ( uint32_t i = lb; i < ub; i++ ) { pos_seen[i] = false; }
    for ( uint32_t i = lb; i < ub; i++ ) { 
      uint32_t to_i = to[j][i];
      pos_seen[to_i] = true;
    }
    for ( uint32_t i = lb; i < ub; i++ ) { 
      if ( !pos_seen[i] ) { go_BYE(-1); }
    }
  }
  //-----------------------------------------
  // START: Decide which feature, which value is best split 
  uint32_t split_i = lb + ((ub - lb)/2); // just for now 
  //---------------------------------------------------
  for ( uint32_t j = 0; j < m; j++ ) {
    uint32_t idx, lidx = 0, ridx = split_i;
    uint64_t *Yj = Y[j];
    // TODO Uncomment this: if ( j == split_j ) { continue; }
    for ( uint32_t i = lb; i < ub; i++ ) { 
      uint32_t from_i = get_from(Y[j][i]);
      uint32_t yval_i = get_yval(Y[j][i]);
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
    if ( ridx != n ) { go_BYE(-1); }
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
  split_j++; if ( split_j == m ) { split_j = 0; }  // TODO FIX 

BYE:
  free_if_non_null(pos_seen);
  free_if_non_null(tos);
  return status;
}
