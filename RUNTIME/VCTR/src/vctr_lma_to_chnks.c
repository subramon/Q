#include "q_incs.h"
#include "qtypes.h"
#include "vctr_consts.h"
#include "cmem_struct.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "vctr_is.h"
#include "vctr_add.h"
#include "vctr_put_chunk.h"
#include "rs_mmap.h"
#include "l2_file_name.h"
#include "mod_mem_used.h"
#include "get_file_size.h"
#include "chnk_get_data.h"
#include "file_exists.h"
#include "chnk_is.h"
#include "mk_file.h"
#include "vctr_lma_to_chnks.h"

extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

int
vctr_lma_to_chnks(
    uint32_t tbsp,
    uint32_t uqid,
    int level // whether to write to l1 mem or l2 mem 
    )
{
  int status = 0;
  char *lma_file = NULL;

  if ( tbsp != 0 ) { go_BYE(-1); } // TODO P4 Consider relaxing 
  if ( uqid == 0 ) { go_BYE(-1); } 
  if ( !( (level == 1) || ( level == 2 ))) { go_BYE(-1); }

  bool vctr_is_found; uint32_t vctr_where_found;
  status = vctr_is(tbsp, uqid, &vctr_is_found, &vctr_where_found); 
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }
  vctr_rs_hmap_val_t v = g_vctr_hmap[tbsp].bkts[vctr_where_found].val;
  //--------------------------
  if ( v.is_lma == false ) { go_BYE(-1); }
  if ( v.is_eov == false ) { go_BYE(-1); } 
  // cannot convert to chunks if in use 
  if ( v.num_readers != 0 ) { go_BYE(-1); }
  if ( v.num_writers != 0 ) { go_BYE(-1); }
  //--------------------------
  // locate backup file 
  lma_file = l2_file_name(tbsp, uqid, ((uint32_t)~0));
  if ( lma_file == NULL ) { go_BYE(-1); }
  if ( !file_exists(lma_file) ) { go_BYE(-1); } 
  int64_t filesz = get_file_size(lma_file); 
  if ( filesz <= 0 ) { go_BYE(-1); } 
  // get access to lma if not present
  if ( v.X == NULL ) { 
    status = rs_mmap(lma_file, &(v.X), &(v.nX), 1); cBYE(status); 
  }
  if ( ( v.X == NULL ) || ( v.nX == 0 ) ) { go_BYE(-1); } 
  // Note that chunks are created in your table space even if
  // vector is not from your table space
  // Determine number of chunks 
  if ( v.max_num_in_chnk == 0 ) { go_BYE(-1); }
  v.num_chnks = v.num_elements / v.max_num_in_chnk;
  if ( (v.num_chnks *  v.max_num_in_chnk) != v.num_elements ) {
    v.num_chnks++;
  }
  // Create chunks from X, nX
  for ( uint32_t chnk_idx = 0; chnk_idx < v.num_chnks; chnk_idx++ ) {
    bool chnk_is_found; uint32_t chnk_where; 
    status = chnk_is(tbsp, uqid, chnk_idx, &chnk_is_found,
        &chnk_where);
    if ( !chnk_is_found ) { go_BYE(-1); }
    chnk_rs_hmap_val_t *ptr_chnk=&(g_chnk_hmap[tbsp].bkts[chnk_where].val);
    uint32_t pre = ptr_chnk->num_readers;
    char *chnk_data = chnk_get_data(tbsp, chnk_where, false);
    if ( chnk_data == NULL ) { 
      char *Y = v.X + (uint64_t)(v.width*chnk_idx)*(uint64_t)v.max_num_in_chnk;
      uint32_t bytes_to_copy = v.width * ptr_chnk->num_elements;
      if ( level == 1 ) { 
        status = posix_memalign((void **)&(ptr_chnk->l1_mem), 
            Q_VCTR_ALIGNMENT, ptr_chnk->size);
        cBYE(status);
        memcpy(ptr_chnk->l1_mem, Y, bytes_to_copy);
        incr_mem_used(ptr_chnk->size);
      }
      else {
        char *Z = NULL; size_t nZ = 0; 
        char *l2_file = NULL;
        if ( ptr_chnk->l2_exists ) { go_BYE(-1); } 
        l2_file = l2_file_name(tbsp, uqid, chnk_idx);
        if ( l2_file == NULL ) { go_BYE(-1); }
        status = mk_file(NULL, l2_file, ptr_chnk->size);
        status = rs_mmap(l2_file, &Z, &nZ, 1); cBYE(status);
        memcpy(Z, Y, bytes_to_copy);
        ptr_chnk->l2_exists = true;
        incr_dsk_used(ptr_chnk->size);
        free_if_non_null(l2_file);
      }
    }
    ptr_chnk->num_readers = pre;
  }
  munmap(v.X, v.nX);
  // release access to lma 
  if ( v.X != NULL ) { 
    munmap(v.X, v.nX); v.X = NULL; v.nX = 0;
  }
BYE:
  free_if_non_null(lma_file);
  return status;
}
