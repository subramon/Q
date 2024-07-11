#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_get.h"
#include "vctr_is.h"
#include "rs_mmap.h"
#include "l2_file_name.h"
#include "mod_mem_used.h"
#include "vctr_append.h"

extern vctr_rs_hmap_t *g_vctr_hmap;

int
vctr_append(
    uint32_t dst_tbsp,
    uint32_t dst_vctr_uqid,
    uint32_t src_tbsp,
    uint32_t src_vctr_uqid
    )
{
  int status = 0;
  char *dst_lma_file = NULL, *src_lma_file = NULL;
  FILE *dst_fp = NULL;
  char *src_X = NULL; size_t src_nX = 0;
  // can append only if dst is in your tablespace
  if ( dst_tbsp != 0 ) { goto BYE; } 

  //------------------------------------------------------
  bool dst_is_found; uint32_t dst_where_found = ~0;
  vctr_rs_hmap_key_t dst_key = dst_vctr_uqid;
  vctr_rs_hmap_val_t dst_val; 
  memset(&dst_val, 0, sizeof(vctr_rs_hmap_val_t));
  status = vctr_rs_hmap_get(&g_vctr_hmap[dst_tbsp], 
      &dst_key, &dst_val, &dst_is_found, &dst_where_found);
  if ( !dst_is_found ) { go_BYE(-1); }
  if ( !dst_val.is_eov ) { go_BYE(-1); }
  if ( !dst_val.is_lma ) { go_BYE(-1); }
  if ( dst_val.num_readers != 0 ) { go_BYE(-1); }
  if ( dst_val.num_writers != 0 ) { go_BYE(-1); }
  dst_lma_file = l2_file_name(dst_tbsp, dst_vctr_uqid, ((uint32_t)~0));
  if ( dst_lma_file == NULL ) { go_BYE(-1); }
  //------------------------------------------------------
  bool src_is_found; uint32_t src_where_found = ~0;
  vctr_rs_hmap_key_t src_key = src_vctr_uqid;
  vctr_rs_hmap_val_t src_val; 
  memset(&src_val, 0, sizeof(vctr_rs_hmap_val_t));
  status = vctr_rs_hmap_get(&g_vctr_hmap[src_tbsp], 
      &src_key, &src_val, &src_is_found, &src_where_found);
  if ( !src_is_found ) { go_BYE(-1); }
  if ( !src_val.is_eov ) { go_BYE(-1); }
  if ( !src_val.is_lma ) { go_BYE(-1); }
  if ( src_val.num_readers != 0 ) { go_BYE(-1); }
  if ( src_val.num_writers != 0 ) { go_BYE(-1); }
  src_lma_file = l2_file_name(src_tbsp, src_vctr_uqid, ((uint32_t)~0));
  if ( src_lma_file == NULL ) { go_BYE(-1); }
  status = rs_mmap(src_lma_file, &src_X, &src_nX, 1); cBYE(status);
  //------------------------------------------------------
  if ( src_val.qtype != dst_val.qtype ) { go_BYE(-1); }
  if ( src_val.num_elements == 0 ) { go_BYE(-1); }
  // -- append and modify dst vector
  dst_fp = fopen(dst_lma_file, "a");
  return_if_fopen_failed(dst_fp, dst_lma_file, "a");
  size_t nw = fwrite(src_X, 1, src_nX, dst_fp);
  if ( nw != src_nX ) { go_BYE(-1); }
  g_vctr_hmap[dst_tbsp].bkts[dst_where_found].val.num_elements += 
    src_val.num_elements;
  status = incr_dsk_used(src_nX); cBYE(status);

  //------------------------------------------------------

BYE:
  fclose_if_non_null(dst_fp);
  if ( src_X != NULL ) { munmap(src_X, src_nX); }
  free_if_non_null(dst_lma_file);
  free_if_non_null(src_lma_file);
  return status;
}
