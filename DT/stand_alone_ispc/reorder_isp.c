#include "macros.h"
export void
reorder_isp(
    uniform uint64 Yj[],
    uniform uint64 tmpYj[], 
    uniform uint32 to_j[],
    uniform uint32 to_split_j[],
    uniform uint32 lb,
    uniform uint32 ub,
    uniform uint32 split_yidx,
    uniform uint32 ptr_lidx[],
    uniform uint32 ptr_ridx[],
    uniform int32 status[]
    )
{
  status[0] = 0;
  uniform uint32 lidx = *ptr_lidx;
  uniform uint32 ridx = *ptr_ridx;

  foreach ( i = lb ... ub ) { 
    varying uint64 Yj_i = Yj[i];
    varying uint32 from_i = Yj_i >> 32; // get_from(Yj[i]);
    varying uint32 to_i   = to_split_j[from_i];
    //-----------------------------------------
    if ( to_i < split_yidx ) { // this data point went left
      int pos = exclusive_scan_add(1);
      to_j[from_i] = lidx + pos;
      lidx += packed_store_active(&(tmpYj[lidx]), Yj_i);
    }
    else {
      int pos = exclusive_scan_add(1);
      to_j[from_i] = ridx + pos;
      ridx += packed_store_active(&(tmpYj[ridx]), Yj_i);
    }
    //------------------------
  }
#ifdef DEBUG
  if ( ( ( lidx - ptr_lidx[0] ) + ( ridx - ptr_ridx[0] ) ) 
      != ( ub - lb ) ) {
    status[0] = -1;
  }
#endif 
  ptr_lidx[0] = lidx;
  ptr_ridx[0] = ridx;
}
