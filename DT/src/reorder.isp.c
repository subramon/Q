#include "constants.h"
#include "macros.h"
export void
reorder(
    uniform uint64 Yj[],
    uniform uint64 tmpYj[],
    uniform uint32 to_j[],
    uniform uint32 to_split_j[],
    uniform uint32 lb,
    uniform uint32 ub,
    uniform uint32 split_yidx,
    uniform uint32 ptr_lidx[],
    uniform uint32 ptr_ridx[]
    )
{
  int status = 0;
  uniform uint32 lidx = *ptr_lidx;
  uniform uint32 ridx = *ptr_ridx;
  /* start ispc */
  for ( uint32 i = lb; i < ub; i++ ) {
    uint32 from_i = Yj[i] >> 32; // get_from(Yj[i]);
    uint32 to_i   = to_split_j[from_i];
    //-----------------------------------------
    if ( to_i < split_yidx ) { // this data point went left
      uniform uint32 * uniform Yd = (uint32 *)tmpYj; 
      Yd += 2*lidx;

      uint32 Yj_i = (Yj[i] >> 32);
      uniform int num_left =  packed_store_active(Yd, Yj_i);

      Yj_i = Yj[i] & 0xFFFFFFFF;
      num_left =  packed_store_active(Yd, Yj_i);

      int pos = exclusive_scan_add(1);
      lidx += num_left;
      // TODO: to_j[from_i] = pos;
    }
    else {
      uniform int num_right =  packed_store_active(tmpYj + ridx, Yj[i]);
      int pos = exclusive_scan_add(1);
      ridx += num_right;
    }
    //------------------------
  }
  ptr_lidx[0] = lidx;
  ptr_ridx[0] = ridx;
}
