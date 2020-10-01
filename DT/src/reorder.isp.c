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
    int pos, is_left, is_right;
    uint32 from_i = Yj[i] >> 32; // get_from(Yj[i]);
    uint32 to_i   = to_split_j[from_i];
    //-----------------------------------------
    is_left = 0;
    if ( to_i < split_yidx ) { // this data point went left
      is_left = 1;
      pos = lidx + exclusive_scan_add(is_left);
      tmpYj[pos] = Yj[i];
      to_j[from_i] = pos;
      /* Following is an experiment based on ISPC documentation
       * uniform float a[] = ...;
       int index = ...;
       float * ptr = &a[index];
       *ptr = 1;
       */
      uint32 * ptr = &(to_j[from_i]);
      *ptr = pos;
    }
    lidx += reduce_add(is_left);
    //------------------------
    is_right = ~is_left;
    if ( is_right == 1 ) {  // this data point went right
      pos = ridx + exclusive_scan_add(is_right);
      tmpYj[pos] = Yj[i];
      to_j[from_i] = pos;
    }
    ridx += reduce_add(is_right);
    //------------------------
  }
  ptr_lidx[0] = lidx;
  ptr_ridx[0] = ridx;
}
