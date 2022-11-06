#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "vctr_get_chunk.h"
#include "chnk_get_data.h"

extern vctr_rs_hmap_t g_vctr_hmap[Q_MAX_NUM_TABLESPACES];
extern chnk_rs_hmap_t g_chnk_hmap[Q_MAX_NUM_TABLESPACES];

int
vctr_get_chunk(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t *ptr_n, // number in chunk
    uint32_t *ptr_num_readers
    )
{
  int status = 0;
  bool vctr_is_found, chnk_is_found;
  uint32_t vctr_where_found, chnk_where_found;
  uint32_t chnk_size, width, is_lma, max_num_in_chnk;
  bool is_write = false; // TODO P3 Handle case when this is true 

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }

  // TODO P0 Implement is_lma
  is_lma = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.is_lma;
  width  = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.width;
  max_num_in_chnk = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.max_num_in_chnk;
  chnk_size = width * max_num_in_chnk;
  //-------------------------------
  status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found, &chnk_where_found);
  cBYE(status);
  if ( chnk_is_found == false ) { 
    status = -1; goto BYE; // go_BYE(-1); TODO P3 Return silently?
  }
  if ( ptr_num_readers != NULL ) { 
    *ptr_num_readers = g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_readers;
    goto BYE; // NOTE early exit
  }
  //-----------------------------------------------------
  // TODO Handle case when data has been flushed to l2/l4 mem
  if ( ptr_cmem != NULL ) { 
    char *data = chnk_get_data(tbsp, chnk_where_found, is_write); 
    if ( data == NULL ) { go_BYE(-1); }

    memset(ptr_cmem, 0, sizeof(CMEM_REC_TYPE));
    ptr_cmem->data  = data;
    ptr_cmem->qtype = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.qtype; 
    ptr_cmem->size  = chnk_size;
    ptr_cmem->is_foreign  = true;
    ptr_cmem->is_stealable  = false;
    g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_readers++;
  }
  if ( ptr_n != NULL ) { 
    *ptr_n = g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_elements; 
  }
BYE:
  return status;
}

int
vctr_unget_chunk(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx
    )
{
  int status = 0;
  status = vctr_get_chunk(tbsp, vctr_uqid, chnk_idx, NULL, NULL, NULL);
  cBYE(status);
BYE:
  return status;
}

int
vctr_num_readers(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    uint32_t *ptr_num_readers
    )
{
  int status = 0;
  status = vctr_get_chunk(tbsp, vctr_uqid, chnk_idx, NULL, NULL, ptr_num_readers);
  cBYE(status);
BYE:
  return status;
}
