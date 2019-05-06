#include "q_incs.h"
#include "_copy_bits.h"

//START_FUNC_DECL
int
copy_bits(
    unsigned char *dest,
    unsigned char *src,
    int dest_start_index,
    int src_start_index,
    int length
)
//STOP_FUNC_DECL
{

  for ( int i = 0; i < length; i++ ) {
    int src_bit = GET_BIT( src, src_start_index + i );
    if ( src_bit ) {
      SET_BIT( dest, dest_start_index + i );
    }
    else
    {
      CLEAR_BIT( dest, dest_start_index + i );
    }
  }
  return 0;
}

