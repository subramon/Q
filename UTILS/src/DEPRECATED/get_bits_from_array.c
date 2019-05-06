#include "q_incs.h"
#include "_get_bits_from_array.h"
//START_FUNC_DECL
int
get_bits_from_array(
    unsigned char *input_arr,
    int *arr,
    int length
)
//STOP_FUNC_DECL
{
  for ( int i = 0; i < length; i++ ) {
    arr[i] = GET_BIT( input_arr, i );
  }
  return 0;
}
