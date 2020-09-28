#include "incs.h"
#include "reorder.h"
int
reorder(
    uint64_t *Yj,
    uint64_t *tmpYj,
    uint32_t *to_j,
    uint32_t *to_split_j,
    uint32_t lb,
    uint32_t ub,
    uint32_t split_yidx,
    uint32_t *ptr_lidx,
    uint32_t *ptr_ridx
    )
{
  int status = 0; 
  register uint32_t lidx = *ptr_lidx;
  register uint32_t ridx = *ptr_ridx;
  /* start ispc */
  for ( uint32_t i = lb; i < ub; i++ ) { 
    uint32_t idx;
    uint32_t from_i = get_from(Yj[i]);
    uint32_t to_i   = to_split_j[from_i];
    if ( to_i < split_yidx ) { // this data point went left
      idx = lidx; tmpYj[lidx++] = Yj[i]; 
    }
    else { // this data point went right
      idx = ridx; tmpYj[ridx++] = Yj[i]; 
    }
    to_j[from_i] = idx;
  }
  *ptr_lidx = lidx;
  *ptr_ridx = ridx;
BYE:
  return status;
}