#include "q_incs.h"
#include "qtypes.h"
#include "vctr_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_cnt.h"
#include "chnk_is.h"
#include "vctr_put.h"

extern vctr_rs_hmap_t g_vctr_hmap;
extern chnk_rs_hmap_t g_chnk_hmap;

int
vctr_put(
    uint32_t vctr_uqid,
    char *X,
    uint32_t n // number of elements
    )
{
  int status = 0;
  bool is_found; uint32_t vctr_where, chnk_where;

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
  uint32_t width = vctr_val.width;
  uint32_t chnk_idx;
  // handle special case for empty vector 
  if ( vctr_val.num_elements == 0 ) { 
    chnk_idx = 0;
    //-------------------------------
    chnk_rs_hmap_key_t chnk_key = 
    { .vctr_uqid = vctr_uqid, .chnk_idx = chnk_idx };
    char *l1_mem = malloc(width * vctr_val.chnk_size);
    return_if_malloc_failed(l1_mem); 
    chnk_rs_hmap_val_t chnk_val = { .qtype = qtype, .l1_mem = l1_mem };
    l1_mem = NULL;
    //-------------------------------
    status = g_chnk_hmap.put(&g_chnk_hmap, &chnk_key, &chnk_val); 
    cBYE(status);
  }
  else {
    chnk_idx = vctr_val.num_chunks - 1; 
  }
  // find chunk in chunk hmap 
  status = chnk_is(vctr_uqid, chnk_idx, &is_found, &chnk_where); 
  cBYE(status);
  // if insufficient space in this chunk, create one more 
  chnk_rs_hmap_val_t chnk_val = g_chnk_hmap.bkts[chnk_where].val;
  if ( chnk_val.l1_mem == NULL ) { go_BYE(-1); }
  if ( chnk_val.num_elements == vctr_val.chnk_size ) { 
    chnk_idx = vctr_val.num_chunks;
    //--------------------------
    chnk_rs_hmap_key_t chnk_key = 
    { .vctr_uqid = vctr_uqid, .chnk_idx = chnk_idx };
    memset(&chnk_val, 0, sizeof(chnk_rs_hmap_val_t));
    chnk_val.qtype = qtype;
    chnk_val.l1_mem = malloc(width * vctr_val.chnk_size);
    return_if_malloc_failed(chnk_val.l1_mem); 
    status = g_chnk_hmap.put(&g_chnk_hmap, &chnk_key, &chnk_val); 
    cBYE(status);
    g_vctr_hmap.bkts[vctr_where].val.num_chunks++;
    //--------------------------
    status = chnk_is(vctr_uqid, chnk_idx, &is_found, &chnk_where); 
    cBYE(status);
    chnk_val = g_chnk_hmap.bkts[chnk_where].val;
  }
  // now you have access to a chunk where you can write.
  // However, you may have more to write than chunk can hold 
  // find out how much you can copy
  uint32_t n_to_copy = n;
  uint32_t space_in_chunk = vctr_val.chnk_size - chnk_val.num_elements;
  if ( n > space_in_chunk ) { 
    n_to_copy = space_in_chunk;
  }
  memcpy(chnk_val.l1_mem + (n_to_copy * width), X, (n*width));
  // update chunk and vector meta data base on above copy
  g_vctr_hmap.bkts[vctr_where].val.num_elements += n_to_copy;
  g_chnk_hmap.bkts[chnk_where].val.num_elements += n_to_copy;
  // if you still have stuff to copy, then tail recursive call
  // to deal with leftover
  if ( n > space_in_chunk ) {
    status = vctr_put(vctr_uqid, X + (n_to_copy) * width, n - n_to_copy);
    cBYE(status);
  }
BYE:
  return status;
}
