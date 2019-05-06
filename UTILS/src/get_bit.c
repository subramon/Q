#include "_get_bit.h"
//START_FUNC_DECL
int
get_bit(
    unsigned char *x,
    int i
)
//STOP_FUNC_DECL
{
    return x[i / 8] & ( 1 << ( i % 8 ) );
}
