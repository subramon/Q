#include "incs.h"
#include "preproc_j.h"
#include "split.h"

int 
split(
    uint8_t *lr, /* [m][n] */
    uint32_t **from, /* [m][n] */
    uint32_t lb,
    uint32_t ub,
    uint32_t n,
    uint32_t m
   )
{
  int status = 0;
  if ( ub - lb <= MIN_LEAF_SIZE ) { return status; }

  // just for now 
  uint32_t split_k = random() % m;
  uint32_t split_idx = lb + ((ub - lb)/2);

  for ( uint32_t i = lb; i < ub; i++ ) { 
    lr[i] = 0;  // default initialization
  }
  for ( uint32_t i = lb; i < split_idx; i++ ) { 
    uint32_t from_idx = from[split_k][i];
    lr[from_idx] = 1; // indicating left 
  }
  for ( uint32_t i = split_idx; i < ub; i++ ) { 
    uint32_t from_idx = from[split_k][i];
    lr[from_idx] = 2; // indicating right 
  }
  for ( uint32_t i = lb; i < ub; i++ ) { 
    if ( lr[i] == 0 ) { go_BYE(-1); }
  }
BYE:
  return status;
}
