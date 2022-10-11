#include "q_incs.h"
#include "qtypes.h"
#include "vctr_consts.h"
#include "cmem_struct.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_cnt.h"
#include "chnk_is.h"
#include "vctr_put_chunk.h"
#include "mod_mem_used.h"

extern vctr_rs_hmap_t g_vctr_hmap;
extern chnk_rs_hmap_t g_chnk_hmap;

// is_stealable is for the most common way in which we will put 
// data into vectors. In this case, we put a chunk at a time
// The caller can opt to hand over  control of the memory to the vector
// This avoids the memcpy that would be invoked otherwise
// This only works when 
// (1) size of X is vctr.chnk_size
// (2) vctr.num_elements is a multiple of vctr.chnk_size
// Note that the only time when n is less than vctr.chnk_size
// is when we are not going to put any more into the vector
// In other words, is_eov will be set 
int
vctr_put_chunk(
    uint32_t vctr_uqid,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t n // number of elements 1 <= n <= vctr.max_num_in_chnk
    )
{
  int status = 0;
  bool is_found; uint32_t vctr_where;

  if ( vctr_uqid == 0 ) { go_BYE(-1); }
  if ( ptr_cmem->data == NULL ) { go_BYE(-1); }
  if ( n == 0 ) { go_BYE(-1); }

  vctr_rs_hmap_key_t vctr_key = vctr_uqid;
  vctr_rs_hmap_val_t vctr_val; 
  status = g_vctr_hmap.get(&g_vctr_hmap, &vctr_key, &vctr_val, &is_found, 
      &vctr_where);
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); } // vector exists 
  if ( vctr_val.is_trash  ) { go_BYE(-1); }
  if ( vctr_val.is_eov    ) { go_BYE(-1); } // vector can be appended to 
  // cannot put more than can fit in chunk
  if ( n > vctr_val.max_num_in_chnk ) { go_BYE(-1); } 

  qtype_t qtype = vctr_val.qtype;
  uint32_t chnk_size;
  if ( qtype == B1 ) {
    chnk_size = vctr_val.max_num_in_chnk / 8;
    if ( ( chnk_size * 8 ) != vctr_val.max_num_in_chnk ) { go_BYE(-1); }
  }
  else {
    chnk_size = vctr_val.width * vctr_val.max_num_in_chnk;
  }
  uint32_t chnk_idx;
  // number of elements in vector must be multiple of chunk size 
  if ( ( ( vctr_val.num_elements / vctr_val.max_num_in_chnk ) * 
        vctr_val.max_num_in_chnk ) != vctr_val.num_elements ) {
    go_BYE(-1);
  }
  // vector is implicitly at an end if insufficient elements sent
  if ( n < vctr_val.max_num_in_chnk ) { 
    g_vctr_hmap.bkts[vctr_where].val.is_eov = true; 
  }
  // handle special case for empty vector 
  if ( vctr_val.num_elements == 0 ) { 
    chnk_idx = 0;
  }
  else {
    chnk_idx = g_vctr_hmap.bkts[vctr_where].val.max_chnk_idx + 1;
  }
  //-------------------------------
  char *l1_mem = NULL;
  if ( ptr_cmem->is_stealable ) { 
    if ( ptr_cmem->is_foreign ) { go_BYE(-1); }
    l1_mem = ptr_cmem->data;
    // DO NOT DO THIS!! Might be needed by others; ptr_cmem->data = NULL;
    ptr_cmem->size = 0;
    ptr_cmem->is_foreign   = true;
    ptr_cmem->is_stealable = false;
  }
  else {
    status = posix_memalign((void **)&l1_mem, Q_VCTR_ALIGNMENT, chnk_size); 
    cBYE(status);
    status = incr_mem_used(chnk_size); cBYE(status);
    memcpy(l1_mem, ptr_cmem->data, n * vctr_val.width);
  }
  chnk_rs_hmap_key_t chnk_key = 
  { .vctr_uqid = vctr_uqid, .chnk_idx = chnk_idx };
  chnk_rs_hmap_val_t chnk_val = { 
    .qtype = qtype, .l1_mem = l1_mem, .num_elements = n, .size = chnk_size };
  //-------------------------------
  status = g_chnk_hmap.put(&g_chnk_hmap, &chnk_key, &chnk_val); 
  cBYE(status);
  bool chnk_is_found; uint32_t chnk_where_found;
  status = chnk_is(vctr_uqid, chnk_idx, &chnk_is_found, &chnk_where_found);
  if ( !chnk_is_found ) { go_BYE(-1); } 
  // update meta data in vector
  g_vctr_hmap.bkts[vctr_where].val.num_elements += n;
  g_vctr_hmap.bkts[vctr_where].val.num_chnks++; 
  g_vctr_hmap.bkts[vctr_where].val.max_chnk_idx = chnk_idx; 
BYE:
  return status;
}
