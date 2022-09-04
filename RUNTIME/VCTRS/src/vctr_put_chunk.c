#include "q_incs.h"
#include "qtypes.h"
#include "vctr_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_cnt.h"
#include "vctr_put_chunk.h"

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
    char **ptr_X, // [vctr.chnk_size]
    bool is_stealable,
    uint32_t n // number of elements 1 <= n <= vctr.chnk_size
    )
{
  int status = 0;
  bool is_found; uint32_t vctr_where;
  char *X = *ptr_X;

  if ( vctr_uqid == 0 ) { go_BYE(-1); }
  if ( X == NULL ) { go_BYE(-1); }
  if ( n == 0 ) { go_BYE(-1); }

  vctr_rs_hmap_key_t vctr_key = vctr_uqid;
  vctr_rs_hmap_val_t vctr_val; 
  status = g_vctr_hmap.get(&g_vctr_hmap, &vctr_key, &vctr_val, &is_found, 
      &vctr_where);
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); } // vector exists 
  if ( vctr_val.is_trash  ) { go_BYE(-1); }
  if ( vctr_val.is_eov    ) { go_BYE(-1); } // vector can be appended to 
  qtype_t qtype = vctr_val.qtype;
  uint32_t chnk_idx;
  // number of elements in vector must be multiple of chunk size 
  if ( ( ( vctr_val.num_elements / vctr_val.chnk_size ) * 
      vctr_val.chnk_size ) != vctr_val.num_elements ) {
    go_BYE(-1);
  }
  // n cannot be bigger than chunk size 
  if ( n > vctr_val.chnk_size ) { go_BYE(-1); } 
  // vector is implicitly at an end if insufficient elements sent
  if ( n < vctr_val.chnk_size ) { 
    g_vctr_hmap.bkts[vctr_where].val.is_eov = true; 
  }
  // handle special case for empty vector 
  if ( vctr_val.num_elements == 0 ) { 
    chnk_idx = 0;
  }
  else {
    chnk_idx = vctr_val.num_chunks;
  }
  //-------------------------------
  char *l1_mem;
  if ( is_stealable ) { 
    l1_mem = X;
    *ptr_X = NULL;
  }
  else {
    l1_mem = malloc(vctr_val.chnk_size * vctr_val.width);
    return_if_malloc_failed(l1_mem);
    memcpy(l1_mem, X, n * vctr_val.width);
  }
  chnk_rs_hmap_key_t chnk_key = 
  { .vctr_uqid = vctr_uqid, .chnk_idx = chnk_idx };
  chnk_rs_hmap_val_t chnk_val = { 
    .qtype = qtype, .l1_mem = X, .num_elements = n };
  //-------------------------------
  status = g_chnk_hmap.put(&g_chnk_hmap, &chnk_key, &chnk_val); 
  cBYE(status);
  // update meta data in vector
  g_vctr_hmap.bkts[vctr_where].val.num_elements += n;
  g_vctr_hmap.bkts[vctr_where].val.num_chunks++; 
BYE:
  return status;
}
