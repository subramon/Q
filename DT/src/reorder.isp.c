#define get_from(x) ( x >> 32 )
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
  uint32 lidx = ptr_lidx[0];
  uint32 ridx = ptr_ridx[0];
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
  ptr_lidx[0] = lidx;
  ptr_ridx[0] = ridx;
}
