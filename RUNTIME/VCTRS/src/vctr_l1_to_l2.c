#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "vctr_print.h"
#include "backup_chunk_data.h"

extern vctr_rs_hmap_t g_vctr_hmap;
extern chnk_rs_hmap_t g_chnk_hmap;

int
vctr_l1_to_l2(
    uint32_t vctr_uqid,
    uint32_t nn_vctr_uqid
    )
{
  int status = 0;
  FILE *fp = NULL;

  if ( vctr_uqid == 0 ) { go_BYE(-1); }
  if ( nn_vctr_uqid != 0 ) { go_BYE(-1); } // TODO TO BE IMPLEMENTED

  bool vctr_is_found, chnk_is_found;
  qtype_t qtype;
  uint64_t num_elements, num_to_pr, pr_idx; 
  uint32_t vctr_where_found, chnk_where_found;
  uint32_t width, max_num_in_chnk;

  status = vctr_is(vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }
  vct_rs_hmap_val_t *ptr_v = &(g_vctr_rs_hmap.bkts[vctr_where_found]); 

  for ( uint32_t chnk_idx = 0; chnk_idx < ptr_v->num_chunks; chnk_idx++ ) { 
    status = chnk_is(vctr_uqid, chnk_idx, &chnk_is_found,&chnk_where_found);
    cBYE(status);
    if ( !chnk_is_found ) { go_BYE(-1); }
    chnk_rs_hmap_key_t *ptr_chnk_key = 
      &(g_chnk_hmap.bkts[chnk_where_found].key); 
    chnk_rs_hmap_key_t *ptr_chnk_val = 
      &(g_chnk_hmap.bkts[chnk_where_found].val); 

    status = backup_chunk_data(ptr_chnk_key, ptr_chnk_val); cBYE(status);
  }
BYE:
  return status;
}
