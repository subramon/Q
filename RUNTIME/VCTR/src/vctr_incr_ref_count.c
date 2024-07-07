#include "q_incs.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_incr_ref_count.h"

extern vctr_rs_hmap_t *g_vctr_hmap;

int
vctr_incr_ref_count(
    uint32_t tbsp,
    uint32_t where_found
    )
{
  int status = 0;
  if ( tbsp >= Q_MAX_NUM_TABLESPACES ) { go_BYE(-1); } 
  if ( where_found >= g_vctr_hmap[tbsp].size ) { go_BYE(-1); }
  if ( g_vctr_hmap[tbsp].bkts[where_found].key == 0 ) { go_BYE(-1); }
  /* TODO P1 THINK ABOUT WHETHER THIS CHECK IS CORRECT
   * ESPECIALLY BECUASE WE SET REF_COUNT TO 0 WHEN WE RESTORE SESSION 
  if ( tbsp == 0 ) {
    if ( g_vctr_hmap[tbsp].bkts[where_found].val.ref_count == 0 ) { 
      go_BYE(-1); 
    }
  }
  */
  g_vctr_hmap[tbsp].bkts[where_found].val.ref_count++;
BYE:
  return status;
}
