#include "q_incs.h"
#include "q_macros.h"
#include "vctr_consts.h"
#include "chnk_rs_hmap_struct.h"
#include "rs_mmap.h"
#include "isfile.h"
#include "l2_file_name.h"
#include "chnk_is.h"
#include "chnk_nop.h"
#include "mod_mem_used.h"

extern chnk_rs_hmap_t *g_chnk_hmap;
int  
chnk_nop(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx
    )
{
  int status = 0;
  char *l2_file = NULL; 
  bool chnk_is_found; uint32_t chnk_where_found;

  status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found,
      &chnk_where_found);
  cBYE(status);
  if ( !chnk_is_found ) { printf("Chunk %u not found \n", chnk_idx); go_BYE(-1); }

  chnk_rs_hmap_val_t *ptr_val =
    &(g_chnk_hmap[tbsp].bkts[chnk_where_found].val);

  if ( ptr_val->l2_exists) { 
    // make l2 before deleting l1 
    l2_file = l2_file_name(tbsp, vctr_uqid, chnk_idx);
  }
BYE:
  free_if_non_null(l2_file);
  return status; 
}
