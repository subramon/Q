#include "incs.h"
#include "reorder.h"
extern int g_num_swaps;
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

  // following condition should have been checked by caller
  if ( Yj[lb] == Yj[ub-1] ) { go_BYE(-1); }

  // 32 is just a guess
  for ( uint32_t i = lb; i < ub; i++ ) { 
    __builtin_prefetch(Yj+i+32, 0, 0);
    
    register uint32_t idx;
    register uint32_t from_i = get_from(Yj[i]);
    register uint32_t to_i   = to_split_j[from_i];
    if ( to_i < split_yidx ) { // this data point went left
      idx = lidx; 
      __builtin_prefetch(tmpYj+lidx+32, 1, 0);
      tmpYj[lidx++] = Yj[i]; 
    }
    else { // this data point went right
      idx = ridx; 
      __builtin_prefetch(tmpYj+ridx+32, 1, 0);
      tmpYj[ridx++] = Yj[i]; 
    }
    to_j[from_i] = idx;
#ifdef SEQUENTIAL
    g_num_swaps++;
#endif
  }
#ifdef DEBUG
  if ( ( ( lidx - ptr_lidx[0] ) + ( ridx - ptr_ridx[0] ) ) 
      != ( ub - lb ) ) { 
    go_BYE(-1);
  }
#endif 
  *ptr_lidx = lidx;
  *ptr_ridx = ridx;
BYE:
  return status;
}
