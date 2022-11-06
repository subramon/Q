#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_is.h"
#include "l2_file_name.h"
#include "mod_mem_used.h"
#include "get_file_size.h"
#include "file_exists.h"
#include "vctr_del_lma.h"


extern vctr_rs_hmap_t g_vctr_hmap[Q_MAX_NUM_TABLESPACES];
int
vctr_del_lma(
    uint32_t tbsp,
    uint32_t vctr_uqid
    )
{
  int status = 0;
  char *lma_file = NULL;

  bool vctr_is_found; uint32_t vctr_where_found;
  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found); 
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }
  vctr_rs_hmap_val_t val = g_vctr_hmap[tbsp].bkts[vctr_where_found].val;
  if ( !val.is_lma ) { go_BYE(-1); }

  // TODO TODO P0
  // Note that file is created in your table space even if
  // vector is not from your table space
  // THINK ABOUT chnks_to_lma.c 
  lma_file = l2_file_name(0, vctr_uqid, ((uint32_t)~0));
  if ( lma_file == NULL ) { go_BYE(-1); }
  int64_t filesz = get_file_size(lma_file); 
  if ( filesz <= 0 ) { go_BYE(-1); } 
  if ( !file_exists(lma_file) ) { go_BYE(-1); } 
  unlink(lma_file);
  status = decr_dsk_used(filesz); cBYE(status);

  g_vctr_hmap[tbsp].bkts[vctr_where_found].val.is_lma = false; 
BYE:
  free_if_non_null(lma_file);
  return status;
}
