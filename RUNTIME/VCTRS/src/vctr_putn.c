#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_cnt.h"
#include "chnk_is.h"
#include "chnk_first.h"
#include "vctr_putn.h"
#include "mod_mem_used.h"


extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

// cannot add to a different tablespace => tbsp = 0
int
vctr_putn(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    char *X,
    uint32_t n // number of elements
    )
{
  int status = 0;
  bool is_found; uint32_t vctr_where, chnk_where;
  chnk_rs_hmap_val_t chnk_val;

  // Cannot put to vector NOT in your tablespace
  if ( tbsp != 0 ) { go_BYE(-1); }
  if ( vctr_uqid == 0 ) { go_BYE(-1); }
  if ( X == NULL ) { go_BYE(-1); }
  if ( n == 0 ) { go_BYE(-1); }

  vctr_rs_hmap_key_t vctr_key = vctr_uqid;
  vctr_rs_hmap_val_t vctr_val; 
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &vctr_key, &vctr_val, 
      &is_found, &vctr_where);
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); } // vector exists 
  if ( vctr_val.is_eov    ) { go_BYE(-1); } // vector can be appended to 
  qtype_t qtype = vctr_val.qtype;
  uint32_t width = vctr_val.width;
  uint32_t chnk_size = width * vctr_val.max_num_in_chnk;
  // handle special case for empty vector with no chunks in it 
  status = chnk_first(tbsp, vctr_where); cBYE(status); 
  // reset vctr_val because chnk_first makes changes
  vctr_val = g_vctr_hmap[tbsp].bkts[vctr_where].val;

  uint32_t chnk_idx = vctr_val.max_chnk_idx; 
  // find chunk in chunk hmap 
  status = chnk_is(tbsp, vctr_uqid, chnk_idx, &is_found, &chnk_where); 
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); } 
  chnk_val = g_chnk_hmap[tbsp].bkts[chnk_where].val;
  if ( chnk_val.l1_mem == NULL ) { go_BYE(-1); }
  // if insufficient space in this chunk, create one more 
  if ( chnk_val.num_elements == vctr_val.max_num_in_chnk ) { 
    chnk_idx++;
    //--------------------------
    chnk_rs_hmap_key_t chnk_key = 
    { .vctr_uqid = vctr_uqid, .chnk_idx = chnk_idx };
    char *l1_mem = NULL;
#ifdef VERBOSE
    printf("VCTR B Malloc of %u for [%s] \n", chnk_size, vctr_val.name);
#endif
    status = posix_memalign((void **)&l1_mem, Q_VCTR_ALIGNMENT,
        chnk_size);
    cBYE(status);
    memset(&chnk_val, 0, sizeof(chnk_rs_hmap_val_t));
    chnk_val.l1_mem = l1_mem; l1_mem = NULL;
    chnk_val.qtype = qtype;
    chnk_val.size  = chnk_size;
    status = incr_mem_used( chnk_size);
    //-------------------------------
    status = g_chnk_hmap[tbsp].put(&g_chnk_hmap[tbsp], &chnk_key, &chnk_val); 
    cBYE(status);
    g_vctr_hmap[tbsp].bkts[vctr_where].val.num_chnks++;
    g_vctr_hmap[tbsp].bkts[vctr_where].val.max_chnk_idx = chnk_idx; 
    //--------------------------
    status = chnk_is(tbsp, vctr_uqid, chnk_idx, &is_found, &chnk_where); 
    cBYE(status);
    chnk_val = g_chnk_hmap[tbsp].bkts[chnk_where].val;
  }
  // now you have access to a chunk where you can write.
  // However, you may have more to write than chunk can hold 
  // find out how much you can copy
  uint32_t n_to_copy = n;
  uint32_t space_in_chunk = 
    vctr_val.max_num_in_chnk - chnk_val.num_elements;
  if ( n > space_in_chunk ) { 
    n_to_copy = space_in_chunk;
  }
  uint32_t num_in_chnk = chnk_val.num_elements;
  memcpy(chnk_val.l1_mem + (num_in_chnk * width), X, (n_to_copy*width));
  // update chunk and vector meta data base on above copy
  g_vctr_hmap[tbsp].bkts[vctr_where].val.num_elements += n_to_copy;
  g_chnk_hmap[tbsp].bkts[chnk_where].val.num_elements += n_to_copy;
  // if you still have stuff to copy, then tail recursive call // to deal with leftover
  if ( n > space_in_chunk ) {
    status = vctr_putn(tbsp, vctr_uqid, X + (n_to_copy * width), n - n_to_copy);
    cBYE(status);
  }
BYE:
  return status;
}
