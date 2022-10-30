#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_is.h"
#include "l2_file_name.h"
#include "mod_mem_used.h"
#include "get_file_size.h"
#include "file_exists.h"
#include "vctr_unmake_lma.h"

extern vctr_rs_hmap_t g_vctr_hmap;

int
vctr_unmake_lma(
    uint32_t vctr_uqid
    )
{
  int status = 0;
  char *lma_file = NULL;

  bool vctr_is_found; uint32_t vctr_where_found;
  status = vctr_is(vctr_uqid, &vctr_is_found, &vctr_where_found); 
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }
  vctr_rs_hmap_val_t val = g_vctr_hmap.bkts[vctr_where_found].val;
  if ( !val.is_lma ) { go_BYE(-1); }

  lma_file = l2_file_name(vctr_uqid, ((uint32_t)~0));
  if ( lma_file == NULL ) { go_BYE(-1); }
  int64_t filesz = get_file_size(lma_file); 
  if ( filesz <= 0 ) { go_BYE(-1); } 
  if ( !file_exists(lma_file) ) { go_BYE(-1); } 
  unlink(lma_file);
  incr_dsk_used(filesz);

  g_vctr_hmap.bkts[vctr_where_found].val.is_lma = false; 
BYE:
  free_if_non_null(lma_file);
  return status;
}
