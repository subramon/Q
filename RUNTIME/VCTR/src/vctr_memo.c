#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_get.h"
#include "vctr_is.h"
#include "chnk_del.h"
#include "vctr_memo.h"

extern vctr_rs_hmap_t *g_vctr_hmap;

int
vctr_set_memo(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    int memo_len
    )
{
  int status = 0;
  bool is_found; uint32_t where_found = ~0;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = vctr_rs_hmap_get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { go_BYE(-1); }
  // once vector has elements in it, cannot modify its memo len 
  if ( val.num_elements > 0 ) { go_BYE(-1); } 
  if ( val.is_persist ) { go_BYE(-1); } 
  if ( val.is_memo ) { go_BYE(-1); }  // cannot set twice
  if ( memo_len == 0 ) { goto BYE; } // IMP: treated as nop
  //--------------------------
  g_vctr_hmap[tbsp].bkts[where_found].val.is_memo = true;
  g_vctr_hmap[tbsp].bkts[where_found].val.memo_len = memo_len;
BYE:
  return status;
}

int
vctr_get_memo_len(
    uint32_t tbsp,
    uint32_t uqid,
    bool *ptr_is_memo,
    int *ptr_memo_len
    )
{
  int status = 0;
  bool is_found; uint32_t where;
  vctr_rs_hmap_key_t key = uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = vctr_rs_hmap_get(&g_vctr_hmap[tbsp], &key, &val, &is_found, &where);
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  vctr_rs_hmap_bkt_t *bkts = (vctr_rs_hmap_bkt_t *)g_vctr_hmap[tbsp].bkts;
  *ptr_is_memo  = bkts[where].val.is_memo;
  *ptr_memo_len = bkts[where].val.memo_len;
BYE:
  return status;
}

int
vctr_memo(
    uint32_t vctr_loc,
    uint32_t vctr_uqid
    )
{
  int status = 0;

  vctr_rs_hmap_val_t *ptr_vctr_val = &(g_vctr_hmap[0].bkts[vctr_loc].val);
  if ( ptr_vctr_val->memo_len == 0 ) { return status; }
  if ( ptr_vctr_val->is_eov ) { return status; }

  uint32_t nC = ptr_vctr_val->max_chnk_idx + 1 - ptr_vctr_val->min_chnk_idx;
  if ( nC > ptr_vctr_val->memo_len ) { 
    uint32_t new_min_chnk_idx = 
      ptr_vctr_val->max_chnk_idx + 1 - ptr_vctr_val->memo_len;
    for ( uint32_t chnk_idx = ptr_vctr_val->min_chnk_idx; 
        chnk_idx < new_min_chnk_idx; chnk_idx++ ) { 
      status = chnk_del(0, vctr_uqid, chnk_idx, ptr_vctr_val->is_persist);
      // printf("Deleting chnk %u for vctr %u \n", chnk_idx, vctr_uqid);
    }
    ptr_vctr_val->min_chnk_idx = new_min_chnk_idx;
  }
BYE:
  return status;
}

