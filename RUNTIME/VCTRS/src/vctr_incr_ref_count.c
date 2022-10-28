#include "q_incs.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_incr_ref_count.h"

extern vctr_rs_hmap_t g_vctr_hmap;

int
vctr_incr_ref_count(
    uint32_t where_found
    )
{
  int status = 0;
  if ( where_found >= g_vctr_hmap.size ) { go_BYE(-1); }
  if ( g_vctr_hmap.bkts[where_found].key == 0 ) { go_BYE(-1); }
  if ( g_vctr_hmap.bkts[where_found].val.ref_count == 0 ) { go_BYE(-1); }
  g_vctr_hmap.bkts[where_found].val.ref_count++;
BYE:
  return status;
}
