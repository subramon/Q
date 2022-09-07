#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "vctr_get_chunk.h"

extern vctr_rs_hmap_t g_vctr_hmap;
extern chnk_rs_hmap_t g_chnk_hmap;

int
vctr_get_chunk(
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t *ptr_n // number in chunk
    )
{
  int status = 0;
  bool vctr_is_found, chnk_is_found;
  uint32_t vctr_where_found, chnk_where_found;
  uint32_t chnk_size, width, max_num_in_chnk;

  memset(ptr_cmem, 0, sizeof(CMEM_REC_TYPE));
  *ptr_n = 0;

  status = vctr_is(vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }

  width  = g_vctr_hmap.bkts[vctr_where_found].val.width;
  max_num_in_chnk = g_vctr_hmap.bkts[vctr_where_found].val.max_num_in_chnk;
  chnk_size = width * max_num_in_chnk;
  //-------------------------------
  status = chnk_is(vctr_uqid, chnk_idx, &chnk_is_found, &chnk_where_found);
  cBYE(status);
  if ( chnk_is_found == false ) { go_BYE(-1); }
  //-----------------------------------------------------
  // TODO Handle case when data has been flushed to l2/l4 mem
  ptr_cmem->data  = g_chnk_hmap.bkts[chnk_where_found].val.l1_mem; 
  ptr_cmem->qtype = g_vctr_hmap.bkts[vctr_where_found].val.qtype; 
  ptr_cmem->size  = chnk_size;
  ptr_cmem->is_foreign  = true;
  ptr_cmem->is_stealable  = false;
  *ptr_n = g_chnk_hmap.bkts[chnk_where_found].val.num_elements; 
BYE:
  return status;
}
