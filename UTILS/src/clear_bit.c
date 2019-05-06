#include "_clear_bit.h"
//START_FUNC_DECL
inline int
clear_bit(
    int *x,
    int i
)
//STOP_FUNC_DECL
{
  return x[i / 8] &= ~( 1 << ( i % 8 ) );
}
