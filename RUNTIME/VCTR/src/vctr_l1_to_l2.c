#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "vctr_print.h"
#include "vctr_l1_to_l2.h"
#include "chnk_l1_to_l2.h"


extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;
int
vctr_l1_to_l2(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t nn_vctr_uqid
    )
{
  int status = 0;

  if ( vctr_uqid == 0 ) { go_BYE(-1); }
  if ( nn_vctr_uqid != 0 ) { go_BYE(-1); } // TODO TO BE IMPLEMENTED

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
    status = chnk_l1_to_l2(tbsp, chnk_where_found); cBYE(status);
  }
BYE:
  return status;
}
