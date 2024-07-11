#include "_set_bit.h"
//START_FUNC_DECL
int
set_bit(
    unsigned char *x,
    int i
)
//STOP_FUNC_DECL
{
    return x[i / 8] |= 1 << ( i % 8 );
}
