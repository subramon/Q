#include "q_incs.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_incr_ref_count.h"

extern vctr_rs_hmap_t g_vctr_hmap[Q_MAX_NUM_TABLESPACES];

int
vctr_incr_ref_count(
    uint32_t tbsp,
    uint32_t where_found
    )
{
  int status = 0;
  if ( where_found >= g_vctr_hmap[tbsp].size ) { go_BYE(-1); }
  if ( g_vctr_hmap[tbsp].bkts[where_found].key == 0 ) { go_BYE(-1); }
  if ( g_vctr_hmap[tbsp].bkts[where_found].val.ref_count == 0 ) { go_BYE(-1); }
  g_vctr_hmap[tbsp].bkts[where_found].val.ref_count++;
BYE:
  return status;
}
