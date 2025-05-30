#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_get.h"
#include "chnk_rs_hmap_del.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "chnk_free_resources.h"
#include "chnk_del.h"

extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

int
chnk_del(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    bool is_persist
    )
{
  int status = 0;
  bool vctr_is_found, chnk_is_found;
  uint32_t vctr_where_found, chnk_where_found;

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { return -2; } // NOTE

  chnk_rs_hmap_key_t key = { .vctr_uqid = vctr_uqid, .chnk_idx = chnk_idx };
  chnk_rs_hmap_val_t val; memset(&val, 0, sizeof(chnk_rs_hmap_val_t));
  status = chnk_rs_hmap_get(&g_chnk_hmap[tbsp], &key, &val, 
      &chnk_is_found, &chnk_where_found);
  if ( chnk_is_found == false ) { return -3; } // NOTE 
  if ( g_chnk_hmap[tbsp].nitems == 0 ) { go_BYE(-1); }
  //----------------------------------------------------
  status = chnk_free_resources(tbsp, 
      &(g_chnk_hmap[tbsp].bkts[chnk_where_found].key), 
      &(g_chnk_hmap[tbsp].bkts[chnk_where_found].val), is_persist);
  cBYE(status);
  //-- delete entry in hash table 
  bool is_found;
  status = chnk_rs_hmap_del(&g_chnk_hmap[tbsp], &key, &val, &is_found); 
  cBYE(status);
  if ( is_found == false ) { go_BYE(-1); }
BYE:
  return status;
}
