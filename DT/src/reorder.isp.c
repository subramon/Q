#include "incs.h"
export void
reorder(
    uint64 *Yj,
    uint64 *tmpYj,
    uint32 *to_j,
    uint32 *to_split_j,
    uint32 lb,
    uint32 ub,
    uint32 split_yidx,
    uint32 *ptr_lidx,
    uint32 *ptr_ridx
    )
{
  uint32 lidx = *ptr_lidx;
  uint32 ridx = *ptr_ridx;
  /* start ispc */
  for ( uint32 i = lb; i < ub; i++ ) { 
    uint32 idx;
    uint32 from_i = get_from(Yj[i]);
    uint32 to_i   = to_split_j[from_i];
    bool is_left = to_i < split_yidx;
    if ( is_left ) { 
      idx = lidx; 
      tmpYj[lidx++] = Yj[i]; 
    }
    else { // this data point went right
      idx = ridx; 
      tmpYj[ridx++] = Yj[i]; 
    }
    to_j[from_i] = idx;
  }
  *ptr_lidx = lidx;
  *ptr_ridx = ridx;
}
