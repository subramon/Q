#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "vctr_get1.h"
#include "get_chnk_data.h"

extern vctr_rs_hmap_t g_vctr_hmap;
extern chnk_rs_hmap_t g_chnk_hmap;

int
vctr_get1(
    uint32_t vctr_uqid,
    uint64_t elem_idx,
    SCLR_REC_TYPE *ptr_sclr
    )
{
  int status = 0;

  bool vctr_is_found, chnk_is_found;
  qtype_t qtype;
  uint32_t vctr_where_found, chnk_where_found;
  uint32_t width, max_num_in_chnk;

  status = vctr_is(vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }

  qtype  = g_vctr_hmap.bkts[vctr_where_found].val.qtype;
  width  = g_vctr_hmap.bkts[vctr_where_found].val.width;
  max_num_in_chnk = g_vctr_hmap.bkts[vctr_where_found].val.max_num_in_chnk;
  ptr_sclr->qtype = qtype;

  uint32_t chnk_idx = elem_idx / max_num_in_chnk;
  uint32_t chnk_off = elem_idx % max_num_in_chnk;
  //-------------------------------
  status = chnk_is(vctr_uqid, chnk_idx, &chnk_is_found, &chnk_where_found);
  cBYE(status);
  if ( chnk_is_found == false ) { go_BYE(-1); }
  //-----------------------------------------------------
  chnk_rs_hmap_key_t key = { .vctr_uqid = vctr_uqid, .chnk_idx = chnk_idx};
  char *data  = get_chnk_data(&key, 
      &(g_chnk_hmap.bkts[chnk_where_found].val), false); 
  if ( data == NULL ) { go_BYE(-1); }
  uint32_t num_in_chnk = g_chnk_hmap.bkts[chnk_where_found].val.num_elements;
  if ( (chnk_off+1) > num_in_chnk ) { go_BYE(-1); } // TODO Check boundary

  memcpy(&(ptr_sclr->val), data, width); 
  // Following is needed because get_chnk_data increments num_readers
  g_chnk_hmap.bkts[chnk_where_found].val.num_readers--; 
BYE:
  return status;
}
