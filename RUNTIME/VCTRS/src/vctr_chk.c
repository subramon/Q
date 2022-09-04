#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_is.h"
#include "vctr_chk.h"

extern vctr_rs_hmap_t g_vctr_hmap;

bool
vctr_is(
    uint32_t uqid
    )
{
  int status = 0;
  bool is_found; uint32_t where;
  
  status = vctr_is(uqid, &is_found, &where);
  if ( !is_found ) { return false; }
BYE:
  if ( status < 0 ) { return false; } else { return true; }
}
