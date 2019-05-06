//START_INCLUDES
#include <string.h>
#include "q_incs.h"
//STOP_INCLUDES
#include "_c_copy.h"
//START_FUNC_DECL
int
c_copy(
   void *dst_addr,
   void *src_addr,
   size_t num_in_chunk,
   size_t num_to_copy,
   size_t field_size
)
//STOP_FUNC_DECL
{
  int status = 0;

  if ( num_to_copy  == 0 ) { go_BYE(-1); }
  if ( field_size   == 0 ) { go_BYE(-1); }
  if ( dst_addr == NULL ) { go_BYE(-1); }
  if ( src_addr == NULL ) { go_BYE(-1); }
  char *dst = (char *)dst_addr + (num_in_chunk*field_size);
  memcpy(dst, src_addr, (num_to_copy*field_size));
BYE:
  return status;
}
