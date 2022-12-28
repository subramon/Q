#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "vctr_print.h"
#include "vctr_drop_l1_l2.h"
#include "chnk_drop_l1_l2.h"

extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

int
vctr_drop_l1_l2(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    int level
    )
{
  int status = 0;

  if ( !( ( level == 1 ) || ( level == 2 ) ) ) { go_BYE(-1); }
  if ( vctr_uqid == 0 ) { go_BYE(-1); }

  bool vctr_is_found, chnk_is_found;
  uint32_t vctr_where_found, chnk_where_found;

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }
  vctr_rs_hmap_val_t *ptr_v = &(g_vctr_hmap[tbsp].bkts[vctr_where_found].val); 

  for ( uint32_t chnk_idx = 0; chnk_idx < ptr_v->num_chnks; chnk_idx++ ) { 
    status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found,&chnk_where_found);
    cBYE(status);
    if ( !chnk_is_found ) { go_BYE(-1); }
    chnk_rs_hmap_key_t *ptr_chnk_key = 
      &(g_chnk_hmap[tbsp].bkts[chnk_where_found].key); 
    chnk_rs_hmap_val_t *ptr_chnk_val = 
      &(g_chnk_hmap[tbsp].bkts[chnk_where_found].val); 

    status = chnk_drop_l1_l2(tbsp, ptr_chnk_key, ptr_chnk_val, level); 
    cBYE(status);
    ptr_chnk_val->num_readers = 0;
    ptr_chnk_val->num_writers = 0;
  }
BYE:
  return status;
}
