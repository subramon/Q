#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "cmem_struct.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_is.h"
#include "vctr_add.h"
#include "vctr_put_chunk.h"
#include "rs_mmap.h"
#include "l2_file_name.h"
#include "mod_mem_used.h"
#include "get_file_size.h"
#include "file_exists.h"
#include "vctr_lma_to_chnks.h"

extern vctr_rs_hmap_t *g_vctr_hmap;
int
vctr_lma_to_chnks(
    uint32_t tbsp,
    uint32_t old_uqid,
    uint32_t *ptr_new_uqid
    )
{
  int status = 0;
  char *lma_file = NULL;
  *ptr_new_uqid = 0;

  if ( tbsp != 0 ) { go_BYE(-1); } // TODO P4 Consider relaxing 
  if ( old_uqid == 0 ) { go_BYE(-1); } 

  bool vctr_is_found; uint32_t vctr_where_found;
  status = vctr_is(tbsp, old_uqid, &vctr_is_found, &vctr_where_found); 
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
  lma_file = l2_file_name(tbsp, old_uqid, ((uint32_t)~0));
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
  char *X = v.X;
  uint32_t lb = 0; uint32_t ub = v.max_num_in_chnk;

  // Create output vector 
  uint32_t new_uqid = 0; 
  status = vctr_add1(v.qtype, v.width, v.max_num_in_chnk, -1, &new_uqid);
  cBYE(status);
  // START check that output vector got created
  uint32_t new_where;
  status = vctr_is(0, new_uqid, &vctr_is_found, &new_where); 
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }
#ifdef DEBUG
  if ( g_vctr_hmap[0].bkts[new_where].val.qtype != v.qtype ) { go_BYE(-1); } 
  if ( g_vctr_hmap[0].bkts[new_where].val.width != v.width ) { go_BYE(-1); } 
  if ( g_vctr_hmap[0].bkts[new_where].val.max_num_in_chnk != v.max_num_in_chnk ) { go_BYE(-1); } 
#endif
  // STOP  check that output vector got created

  for ( uint32_t i = 0; i < v.num_chnks; i++ ) {
    CMEM_REC_TYPE cmem; memset(&cmem, 0, sizeof(CMEM_REC_TYPE));
    cmem.data = X;
    if ( ub > v.num_elements ) { 
      ub = v.num_elements;
    }
    uint32_t num_this_chnk = ub - lb;
    cmem.size = v.width * v.max_num_in_chnk;
    if ( *v.name != '\0' ) {
      snprintf(cmem.cell_name, Q_MAX_LEN_CELL_NAME, "chnk_%u", i);
    }
    cmem.qtype = v.qtype;
    cmem.is_foreign = false; 
    cmem.is_stealable = false; 
    status = vctr_put_chunk(tbsp, new_uqid, &cmem, num_this_chnk);
    cBYE(status);
    X += v.width * v.max_num_in_chnk;
    ub += v.max_num_in_chnk;
    lb += v.max_num_in_chnk;

  }
#ifdef DEBUG
  if ( g_vctr_hmap[0].bkts[new_where].val.qtype != v.qtype ) { go_BYE(-1); } 
  if ( g_vctr_hmap[0].bkts[new_where].val.num_elements != v.num_elements ) { go_BYE(-1); } 
  if ( g_vctr_hmap[0].bkts[new_where].val.is_lma ) { go_BYE(-1); } 
#endif
  // release access to lma 
  if ( v.X != NULL ) { 
    munmap(v.X, v.nX); v.X = NULL; v.nX = 0;
  }
  g_vctr_hmap[0].bkts[new_where].val.is_eov = true; 
  g_vctr_hmap[0].bkts[new_where].val.memo_len = -1;

BYE:
  free_if_non_null(lma_file);
  *ptr_new_uqid = new_uqid;
  return status;
}
