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

static int
vctr_get_chunk_lma(
    vctr_rs_hmap_val_t *ptr_val,
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint64_t chnk_idx,
    CMEM_REC_TYPE *ptr_cmem
    )
{
  int status = 0;
  char *lma_file = NULL;
  char *X = NULL; size_t nX = 0;

  if ( ptr_val->is_lma == false ) { go_BYE(-1); }
  if ( ptr_val->num_writers != 0 ) { go_BYE(-1); }
  if ( elem_idx >= ptr_val->num_elements ) { go_BYE(-1); }
  if ( ptr_val->num_readers > 0 ) { 
    X = ptr_val->X;
    nX = ptr_val->nX;
  }
  else {
    lma_file = l2_file_name(tbsp, vctr_uqid, ((uint32_t)~0));
    if ( lma_file == NULL ) { go_BYE(-1); }
    status = rs_mmap(lma_file, &X, &nX, 0); cBYE(status);
  }
  //---------------------------------------------------
  uint32_t width = ptr_val->width;
  uint32_t max_num_in_chunk = ptr_val->max_num_in_chunk;
  size_t chunk_size;
  if ( ptr_val->qtype == B1 ) { 
    chunk_size = max_num_in_chunk / 8;
  }
  else { 
    chunk_size = width * max_num_in_chunk;
  }
  size_t offset = chunk_size * chnk_idx;
  if ( (offset + chunk_size) > nX ) { go_BYE(-1); }
  char *data = X + offset;
  ptr_cmem->data = X;
  ptr_cmem->size = 9999999999999;
  ptr_cmem->is_foreign = true;

  ptr_val->num_readers++; 
BYE:
  return status;
}

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

  is_lma = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.is_lma;
  width  = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.width;
  max_num_in_chnk = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.max_num_in_chnk;
  chnk_size = width * max_num_in_chnk;
  //-------------------------------
  if ( is_lma ) { 
    status = vctr_get_chunk_lma(
        &(g_vctr_hmap[tbsp].bkts[vctr_where_found].val),
           tbsp, vctr_uqid, chnk_idx, ptr_cmem);
    cBYE(status);
    goto BYE;
  }
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

// TODO P0 Make a separate function for this
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

// TODO P0 Make a separate function for this
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
