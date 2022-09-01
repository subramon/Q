#include "q_incs.h"
#include "q_macros.h"
#include "rs_hmap_int_struct.h"
#include "bkt_chk.h"
int
bkt_chk(
    const void *const X,
    uint32_t n
    )
{
  int status = 0;
  if ( X == NULL ) { go_BYE(-1); }
  if ( n == 0 ) { go_BYE(-1); }
BYE:
  return status;
}
