#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "vctr_drop_mem.h"
#include "chnk_drop_mem.h"

// It eliminates memory at level "level" if possible. 
extern vctr_rs_hmap_t *g_vctr_hmap;

int
vctr_drop_mem(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    int level
    )
{
  int status = 0;

  if ( vctr_uqid == 0 ) { go_BYE(-1); }
  if ( ( level < 1 ) || ( level > 2 ) ) { go_BYE(-1); } 

  bool vctr_is_found; uint32_t vctr_where_found;

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }
  uint32_t num_chnks=g_vctr_hmap[tbsp].bkts[vctr_where_found].val.num_chnks;

  for ( uint32_t chnk_idx = 0; chnk_idx < num_chnks; chnk_idx++ ) { 
    status = chnk_drop_mem(tbsp, vctr_uqid, chnk_idx, level); 
    cBYE(status);
  }
BYE:
  return status;
}
