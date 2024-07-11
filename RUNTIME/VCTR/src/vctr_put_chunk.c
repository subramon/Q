#include "q_incs.h"
#include "qtypes.h"
#include "vctr_consts.h"
#include "cmem_struct.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_get.h"
#include "vctr_rs_hmap_put.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_cnt.h"
#include "chnk_is.h"
#include "vctr_put_chunk.h"
#include "mod_mem_used.h"
#include "chnk_del.h"

extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

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
    uint32_t tbsp,
    uint32_t vctr_uqid,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t n // number of elements 1 <= n <= vctr.max_num_in_chnk
    )
{
  int status = 0;
  bool is_found; uint32_t vctr_where;

  if ( vctr_uqid == 0 ) { go_BYE(-1); }
  // Had to allow data == NULL when vector is created from file using 
  // vctr_set_lma and we have to create empty chunks
  // if ( ptr_cmem->data == NULL ) { go_BYE(-1); }
  if ( n == 0 ) { go_BYE(-1); }

  vctr_rs_hmap_key_t vctr_key = vctr_uqid;
  vctr_rs_hmap_val_t vctr_val; 
  status = bvctr_rs_hmap_get(&g_vctr_hmap[tbsp], &vctr_key, 
      &vctr_val, &is_found, &vctr_where);
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); } // vector exists 
  if ( vctr_val.is_eov    ) { go_BYE(-1); } // vector can be appended to 
  // cannot put more than can fit in chunk
  if ( n > vctr_val.max_num_in_chnk ) { go_BYE(-1); } 

  qtype_t qtype = vctr_val.qtype;
  uint32_t chnk_size = ptr_cmem->size; // whatever comes from cmem 
  if ( chnk_size == 0 ) { go_BYE(-1); }
  if ( qtype != B1 ) {
    if ( chnk_size != (vctr_val.width * vctr_val.max_num_in_chnk) ) {
      go_BYE(-1);
    }
  }
  uint32_t chnk_idx;
  // number of elements in vector must be multiple of chunk size 
  if ( ( ( vctr_val.num_elements / vctr_val.max_num_in_chnk ) * 
        vctr_val.max_num_in_chnk ) != vctr_val.num_elements ) {
    go_BYE(-1);
  }
  // vector is implicitly at an end if insufficient elements sent
  if ( n < vctr_val.max_num_in_chnk ) { 
    g_vctr_hmap[tbsp].bkts[vctr_where].val.is_eov = true; 
  }
  // handle special case for empty vector 
  if ( vctr_val.num_elements == 0 ) { 
    chnk_idx = 0;
  }
  else {
    chnk_idx = g_vctr_hmap[tbsp].bkts[vctr_where].val.max_chnk_idx + 1;
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
#ifdef VERBOSE
    printf("%s Malloc of %u for [%s] \n", __FILE__, chnk_size, vctr_val.name);
#endif
    status = posix_memalign((void **)&l1_mem, Q_VCTR_ALIGNMENT, chnk_size); 
    cBYE(status);
    status = incr_mem_used(chnk_size); cBYE(status);
    memcpy(l1_mem, ptr_cmem->data, n * vctr_val.width);
  }
  chnk_rs_hmap_key_t chnk_key = 
  { .vctr_uqid = vctr_uqid, .chnk_idx = chnk_idx };
  chnk_rs_hmap_val_t chnk_val = { 
    .qtype = qtype, .l1_mem = l1_mem, .num_elements = n, .size = chnk_size };
  if ( vctr_val.is_early_freeable ) { 
    chnk_val.num_lives_left = vctr_val.num_lives_free;
  }
  //-------------------------------
  status = vctr_rs_hmap_put(&g_chnk_hmap[tbsp], &chnk_key, &chnk_val); 
  cBYE(status);
  bool chnk_is_found; uint32_t chnk_where_found;
  status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found, &chnk_where_found);
  if ( !chnk_is_found ) { go_BYE(-1); } 
  // update meta data in vector
  g_vctr_hmap[tbsp].bkts[vctr_where].val.num_elements += n;
  g_vctr_hmap[tbsp].bkts[vctr_where].val.num_chnks++; 
  g_vctr_hmap[tbsp].bkts[vctr_where].val.max_chnk_idx = chnk_idx; 
  // If memo_len >= 0 and not the first chunk to be produced 
  if ( ( vctr_val.memo_len >= 0 ) && ( chnk_idx >= 1 ) ) { 
    // Release resources for all previous chunks, keeping only "memo_len"
    int del_chnk_marker = -1; 
    for ( int del_chnk = chnk_idx-1; del_chnk >= 0; del_chnk-- ) { 
      if ( ( (int)chnk_idx - del_chnk - 1 ) >= vctr_val.memo_len ) {
        status = chnk_is(tbsp, vctr_uqid, del_chnk, 
            &chnk_is_found, &chnk_where_found);
        if ( !chnk_is_found ) { go_BYE(-1); } 
        del_chnk_marker = del_chnk; 
        status = chnk_del(tbsp, vctr_uqid, del_chnk, false); 
        cBYE(status); 
        break; // See DEBUG logic below 
      }
    }
#ifdef DEBUG
    // All previous chunks to one just delete should be deleted
    for ( int i = 0; i <= del_chnk_marker; i++ ) { 
      status = chnk_is(tbsp, vctr_uqid, i, 
          &chnk_is_found, &chnk_where_found);
      if ( chnk_is_found ) { go_BYE(-1); } 
    }
#endif
  }
BYE:
  return status;
}
