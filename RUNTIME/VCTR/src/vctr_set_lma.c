#include "q_incs.h"
#include "qtypes.h"
#include "cmem_struct.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_is.h"
#include "l2_file_name.h"
#include "mod_mem_used.h"
#include "get_file_size.h"
#include "file_exists.h"
#include "vctr_put_chunk.h"
#include "vctr_set_lma.h"


extern vctr_rs_hmap_t *g_vctr_hmap;
int
vctr_set_lma(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    const char * const in_file_name,
    uint64_t num_elements
    )
{
  int status = 0;
  char *lma_file = NULL;

  // Cannot modify if not in your tablespace
  if ( tbsp != 0 ) { go_BYE(-1); } 
  if (( in_file_name == NULL ) || ( *in_file_name == '\0' )) { go_BYE(-1); }
  bool vctr_is_found; uint32_t vctr_where_found;
  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found); 
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }
  vctr_rs_hmap_val_t val = g_vctr_hmap[tbsp].bkts[vctr_where_found].val;
  if ( val.is_lma ) { go_BYE(-1); }
  if ( val.X != NULL ) { go_BYE(-1); }
  if ( val.nX != 0 ) { go_BYE(-1); }
  if ( val.num_readers != 0 ) { go_BYE(-1); }
  if ( val.num_writers != 0 ) { go_BYE(-1); }
  if ( val.num_elements != 0 ) { go_BYE(-1); }

  lma_file = l2_file_name(tbsp, vctr_uqid, ((uint32_t)~0));
  if ( lma_file == NULL ) { go_BYE(-1); }
  if ( strcmp(lma_file, in_file_name) == 0 ) { go_BYE(-1); }

  int64_t filesz = get_file_size(in_file_name); 
  if ( filesz <= 0 ) { go_BYE(-1); } 
  if ( !file_exists(in_file_name) ) { go_BYE(-1); } 
  // Check if space exists for file about to be created 
  int64_t dsk_used = get_dsk_used(); 
  int64_t dsk_allowed = get_dsk_allowed(); 
  if ( dsk_allowed < dsk_used ) { go_BYE(-1); }
  if ( dsk_allowed - dsk_used < filesz ) { go_BYE(-1); }
  status = incr_dsk_used(filesz); cBYE(status);
  //-----------------------------------------
  status = rename(in_file_name, lma_file); cBYE(status);

  uint32_t width = val.width;
  if ( width == 0 ) { go_BYE(-1); } 
  if ( num_elements == 0 ) { 
    num_elements = filesz / width;
    if ( ( num_elements * width ) != (uint64_t)filesz ) { go_BYE(-1); }
  }
  else {
    if ( ( num_elements * width ) < (uint64_t)filesz ) { go_BYE(-1); }
  }
  // Create empty chunks 
  if ( val.max_num_in_chnk == 0 ) { go_BYE(-1); } 
  uint32_t num_chunks = num_elements / val.max_num_in_chnk;
  if ( (num_chunks * val.max_num_in_chnk) != num_elements ) { 
    num_chunks++;
  }
  uint32_t num_elements_to_put = num_elements;
  for ( uint32_t chnk_idx = 0; chnk_idx < num_chunks; chnk_idx++ ) {
    CMEM_REC_TYPE cmem; memset(&cmem, 0, sizeof(CMEM_REC_TYPE));
    cmem.is_stealable = true; 
    cmem.is_foreign   = false; 
    uint32_t chnk_num_elements = mcr_min(val.max_num_in_chnk, 
        num_elements_to_put);
    if ( chnk_num_elements == 0 ) { go_BYE(-1); }
    // ??? cmem.size = chnk_num_elements * width;
    cmem.size = val.max_num_in_chnk * width;
    num_elements_to_put -= chnk_num_elements;
    status = vctr_put_chunk(tbsp, vctr_uqid, &cmem, chnk_num_elements);

  }

  g_vctr_hmap[tbsp].bkts[vctr_where_found].val.is_lma = true; 
  g_vctr_hmap[tbsp].bkts[vctr_where_found].val.num_elements = num_elements;
  g_vctr_hmap[tbsp].bkts[vctr_where_found].val.is_eov = true; 
BYE:
  free_if_non_null(lma_file);
  return status;
}
