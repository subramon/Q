#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_consts.h"
#include "sclr_struct.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"
#include "mod_mem_used.h"
#include "chnk_first.h"


extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

int
chnk_first(
    uint32_t tbsp,
    uint32_t vctr_where
    )
{
  int status = 0;
  vctr_rs_hmap_val_t *ptr_vctr_val = &(g_vctr_hmap[tbsp].bkts[vctr_where].val);
  vctr_rs_hmap_key_t vctr_uqid = g_vctr_hmap[tbsp].bkts[vctr_where].key;

  // This function handles case when vector is empty 
  if ( ptr_vctr_val->num_elements != 0 ) { goto BYE; } 

  qtype_t qtype      = ptr_vctr_val->qtype;
  uint32_t width     = ptr_vctr_val->width;
  uint32_t chnk_size = width * ptr_vctr_val->max_num_in_chnk;
  uint32_t chnk_idx = 0;
  //-------------------------------
  chnk_rs_hmap_key_t chnk_key = 
  { .vctr_uqid = vctr_uqid, .chnk_idx = chnk_idx };
  char *l1_mem = NULL;
  status = posix_memalign((void **)&l1_mem, Q_VCTR_ALIGNMENT, chnk_size);
  cBYE(status);
  chnk_rs_hmap_val_t chnk_val;
  memset(&chnk_val, 0, sizeof(chnk_rs_hmap_val_t));
  chnk_val.l1_mem = l1_mem; l1_mem = NULL;
  chnk_val.qtype = qtype;
  chnk_val.size  = chnk_size;
  status = incr_mem_used(chnk_size);  cBYE(status);
  //-------------------------------
  status = g_chnk_hmap[tbsp].put(&g_chnk_hmap[tbsp], &chnk_key, &chnk_val); 
  cBYE(status);
  g_vctr_hmap[tbsp].bkts[vctr_where].val.num_chnks++;
#ifdef DEBUG
  bool is_found; uint32_t chnk_where;
  status = chnk_is(tbsp, vctr_uqid, chnk_idx, &is_found, &chnk_where); 
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); } 
#endif
BYE:
  return status;
}
