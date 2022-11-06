#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "get_bit_u64.h"
#include "l2_file_name.h"
#include "rs_mmap.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "vctr_get1.h"
#include "chnk_get_data.h"

extern vctr_rs_hmap_t g_vctr_hmap[Q_MAX_NUM_TABLESPACES];
extern chnk_rs_hmap_t g_chnk_hmap[Q_MAX_NUM_TABLESPACES];

static int
vctr_get1_lma(
    vctr_rs_hmap_val_t *ptr_val,
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint64_t elem_idx,
    SCLR_REC_TYPE *ptr_sclr
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
  if ( ptr_val->qtype == SC ) { 
    go_BYE(-1); // TODO P2 
  }
  else if ( ptr_val->qtype == B1 ) { 
    go_BYE(-1); // TODO P2 
  }
  else { 
    size_t offset = (ptr_val->width * elem_idx);
    if ( (offset + ptr_val->width) > nX ) { go_BYE(-1); }
    char *data = X + offset;
    memcpy(&(ptr_sclr->val), data, ptr_val->width); 
  }
  if ( ptr_val->num_readers == 0 ) { 
    munmap(X, nX);
    ptr_val->X = NULL;
    ptr_val->nX = 0;
  }
BYE:
  free_if_non_null(lma_file);
  return status;
}
//-------------------------------------------------------
int
vctr_get1(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint64_t elem_idx,
    SCLR_REC_TYPE *ptr_sclr
    )
{
  int status = 0;

  bool vctr_is_found, chnk_is_found;
  qtype_t qtype; bool is_lma;
  uint32_t vctr_where_found, chnk_where_found;
  uint32_t width, max_num_in_chnk;

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }

  is_lma  = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.is_lma;
  qtype  = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.qtype;
  width  = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.width;
  max_num_in_chnk = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.max_num_in_chnk;
  ptr_sclr->qtype = qtype;

  if ( is_lma ) {
    status = vctr_get1_lma(&(g_vctr_hmap[tbsp].bkts[vctr_where_found].val),
        tbsp, vctr_uqid, elem_idx, ptr_sclr); 
    cBYE(status);
    goto BYE; 
  }
  //--------------------------------------------
  uint32_t chnk_idx = elem_idx / max_num_in_chnk;
  uint32_t chnk_off = elem_idx % max_num_in_chnk;
  //-------------------------------
  status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found, &chnk_where_found);
  cBYE(status);
  if ( chnk_is_found == false ) { go_BYE(-1); }
  //-----------------------------------------------------
  char *data  = chnk_get_data(tbsp, chnk_where_found, false); 
  if ( data == NULL ) { go_BYE(-1); }
  uint32_t num_in_chnk = g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_elements;
  if ( (chnk_off+1) > num_in_chnk ) { go_BYE(-1); } // TODO Check boundary
  // offset the pointer to the base of the chunk

  if ( qtype == SC ) { 
    data += (width * chnk_off);
    if ( data[width-1] != '\0' ) { go_BYE(-1); } 
    ptr_sclr->val.str = malloc(width * sizeof(char));
    return_if_malloc_failed(ptr_sclr->val.str);
    memcpy(ptr_sclr->val.str, data, width); 
  }
  else if ( qtype == B1 ) { 
    // Note that we do NOT offset data over here
    ptr_sclr->qtype = BL;
    ptr_sclr->val.bl = get_bit_u64((uint64_t *)data, chnk_off); 
  }
  else { 
    data += (width * chnk_off);
    memcpy(&(ptr_sclr->val), data, width); 
  }
  // Following is needed because chnk_get_data increments num_readers
  g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_readers--; 
BYE:
  return status;
}
