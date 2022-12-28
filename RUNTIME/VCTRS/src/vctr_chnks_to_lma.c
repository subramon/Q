#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "vctr_is.h"
#include "chnk_del.h"
#include "chnk_is.h"
#include "file_exists.h"
#include "mk_file.h"
#include "rs_mmap.h"
#include "chnk_get_data.h"
#include "get_file_size.h"
#include "l2_file_name.h"
#include "mod_mem_used.h"
#include "vctr_chnks_to_lma.h"


extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

int
vctr_chnks_to_lma(
    uint32_t tbsp,
    uint32_t vctr_uqid
    )
{
  int status = 0;
  char *lma_file = NULL;
  char *X = NULL, *bak_X = NULL; size_t nX = 0, bak_nX = 0;

  if ( tbsp != 0 ) { go_BYE(-1); } 
  if ( vctr_uqid == 0 ) { go_BYE(-1); } 
  bool vctr_is_found; uint32_t vctr_where_found;
  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found); 
  cBYE(status);
  if ( !vctr_is_found ) { goto BYE; }
  vctr_rs_hmap_val_t val = g_vctr_hmap[tbsp].bkts[vctr_where_found].val;
  if ( !val.is_eov ) { go_BYE(-1); }
  if ( val.num_elements == 0 ) { go_BYE(-1); }
  if ( val.is_lma ) { goto BYE; } // not an error; nothing to do 

  lma_file = l2_file_name(tbsp, vctr_uqid, ((uint32_t)~0));
  if ( lma_file == NULL ) { go_BYE(-1); }
  if ( file_exists(lma_file) ) { go_BYE(-1); } 

  if ( val.num_readers != 0 ) { go_BYE(-1); }
  if ( val.num_writers != 0 ) { go_BYE(-1); }

  uint32_t width  = val.width;
  uint64_t filesz = val.num_elements * width;
  uint64_t dsk_used = get_dsk_used(); 
  uint64_t dsk_allowed = get_dsk_allowed(); 
  if ( dsk_allowed < dsk_used ) { go_BYE(-1); }
  if ( dsk_allowed - dsk_used < filesz ) { go_BYE(-1); }
  status = incr_dsk_used(filesz); cBYE(status);
  status = mk_file(NULL, lma_file, filesz); cBYE(status);
  status = rs_mmap(lma_file, &X, &nX, 1); cBYE(status); 
  if ( ( X == NULL ) || ( nX == 0 ) ) { go_BYE(-1); }
  bak_X = X; bak_nX = nX;

  uint32_t max_chnk_idx = val.max_chnk_idx; 
  for ( uint32_t chnk_idx = 0; chnk_idx <= max_chnk_idx; chnk_idx++ ) { 
    bool chnk_is_found; uint32_t chnk_where_found;
    status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found,&chnk_where_found);
    cBYE(status);
    if ( !chnk_is_found ) { go_BYE(-1); }
    uint32_t num_in_chnk = 
      g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_elements;
    uint32_t num_readers = 
      g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_readers;
    uint32_t num_writers = 
      g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_writers;
    if ( num_readers != 0 ) { go_BYE(-1); } 
    if ( num_writers != 0 ) { go_BYE(-1); } 
    char *data  = chnk_get_data(tbsp, chnk_where_found, false);
    if ( data == NULL ) { go_BYE(-1); } 
    size_t bytes_to_copy = num_in_chnk * width;
    if ( bytes_to_copy > nX ) { go_BYE(-1); } 
    memcpy(X, data, bytes_to_copy); 
    X  += bytes_to_copy;
    nX -= bytes_to_copy;
    if ( g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_readers != 1 ) {
      go_BYE(-1); 
    }
    g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_readers = 0;

  }
  // Now delete all the chunks 
  for ( uint32_t chnk_idx = 0; chnk_idx <= max_chnk_idx; chnk_idx++ ) { 
    status = chnk_del(tbsp, vctr_uqid, chnk_idx, false); cBYE(status);
  }
  // update meta data 
  g_vctr_hmap[tbsp].bkts[vctr_where_found].val.num_chnks = 0; 
  g_vctr_hmap[tbsp].bkts[vctr_where_found].val.max_chnk_idx = 0; 
  g_vctr_hmap[tbsp].bkts[vctr_where_found].val.is_lma = true; 
BYE:
  if ( status < 0 ) { 
    if ( lma_file != NULL ) { 
      if ( ( file_exists(lma_file) ) && ( tbsp == 0 ) ) {
        unlink(lma_file);
      }
    }
  }
  mcr_rs_munmap(bak_X, bak_nX); // X, nX are modified in the loop
  free_if_non_null(lma_file);
  return status;
}
