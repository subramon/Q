#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "cmem_struct.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "mod_mem_used.h"
#include "file_exists.h"
#include "rdtsc.h"
#include "copy_file.h"
#include "mk_file.h"
#include "rs_mmap.h"
#include "l2_file_name.h"
#include "vctr_is.h"
#include "chnk_is.h"
#include "chnk_get_data.h"
#include "vctr_make_lma.h"

extern vctr_rs_hmap_t g_vctr_hmap[Q_MAX_NUM_TABLESPACES];
extern chnk_rs_hmap_t g_chnk_hmap[Q_MAX_NUM_TABLESPACES];

char *
vctr_make_lma(
    uint32_t src_tbsp,
    uint32_t src_uqid
    )
{
  int status = 0;
  bool is_found; uint32_t where_found = ~0;
  char *dst_lma_file = NULL;
  char *src_lma_file = NULL;
  char *X = NULL, *bak_X = NULL; size_t nX = 0, bak_nX = 0; 
  uint32_t dst_uqid = 0; // We do not know what it should be just yet
  uint32_t dst_tbsp = 0; // Can only create in your own tablespace
  char *tmp = NULL;

  status = vctr_is(src_tbsp, src_uqid, &is_found, &where_found); 
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  vctr_rs_hmap_val_t val = g_vctr_hmap[src_tbsp].bkts[where_found].val;

  // Decide on the output file name 
  dst_lma_file = l2_file_name(dst_tbsp, dst_uqid, ((uint32_t)~0));
  if ( dst_lma_file == NULL ) { go_BYE(-1); }
  if ( file_exists(dst_lma_file) ) { go_BYE(-1); } 
  tmp = malloc(strlen(dst_lma_file) + 32);
  sprintf(tmp, "%s_%" PRIu64 "", dst_lma_file, RDTSC());
  free_if_non_null(dst_lma_file);
  dst_lma_file = tmp; tmp = NULL;
  //----------------------------------------------
  if ( val.is_lma ) { 
    if ( val.num_writers != 0 ) { go_BYE(-1); }
    src_lma_file = l2_file_name(src_tbsp, src_uqid, ((uint32_t)~0));
    if ( src_lma_file == NULL ) { go_BYE(-1); }
    if ( !file_exists(src_lma_file) ) { go_BYE(-1); } 
    // copy source to destination 
    status = copy_file(src_lma_file, dst_lma_file); cBYE(status);
    goto BYE; 
  }
  // Now we need to create the lma file 
  uint32_t width  = val.width;
  uint64_t filesz = val.num_elements * width;
  status = incr_dsk_used(filesz); cBYE(status);
  status = mk_file(NULL, dst_lma_file, filesz); cBYE(status);
  status = rs_mmap(dst_lma_file, &X, &nX, 1); cBYE(status); 
  if ( ( X == NULL ) || ( nX == 0 ) ) { go_BYE(-1); }
  bak_X = X; bak_nX = nX;

  uint32_t max_chnk_idx = val.max_chnk_idx; 
  for ( uint32_t chnk_idx = 0; chnk_idx <= max_chnk_idx; chnk_idx++ ) { 
    bool chnk_is_found; uint32_t chnk_where_found;
    status = chnk_is(src_tbsp, src_uqid, chnk_idx, &chnk_is_found, 
        &chnk_where_found);
    cBYE(status);
    if ( !chnk_is_found ) { go_BYE(-1); }
    uint32_t num_in_chnk = 
      g_chnk_hmap[src_tbsp].bkts[chnk_where_found].val.num_elements;
    char *data  = chnk_get_data(src_tbsp, chnk_where_found, false);
    if ( data == NULL ) { go_BYE(-1); } 
    size_t bytes_to_copy = num_in_chnk * width;
    if ( bytes_to_copy > nX ) { go_BYE(-1); } 
    memcpy(X, data, bytes_to_copy); 
    X  += bytes_to_copy;
    nX -= bytes_to_copy;
  }
  munmap(bak_X, bak_nX); 
BYE:
  free_if_non_null(src_lma_file);
  if ( status == 0 ) { return dst_lma_file; } else { return NULL; } 
}
