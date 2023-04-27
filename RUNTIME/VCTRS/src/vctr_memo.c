#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_is.h"
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
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { go_BYE(-1); }
  // once vector has elements in it, cannot modify its memo len 
  if ( val.num_elements > 0 ) { go_BYE(-1); } 
  //--------------------------
  g_vctr_hmap[tbsp].bkts[where_found].val.memo_len = memo_len;
BYE:
  return status;
}

int
vctr_get_memo_len(
    uint32_t tbsp,
    uint32_t uqid,
    int *ptr_memo_len
    )
{
  int status = 0;
  bool is_found; uint32_t where;
  vctr_rs_hmap_key_t key = uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, &where);
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  if ( val.is_trash ) { go_BYE(-1); }
  vctr_rs_hmap_bkt_t *bkts = (vctr_rs_hmap_bkt_t *)g_vctr_hmap[tbsp].bkts;
  *ptr_memo_len = bkts[where].val.memo_len;
BYE:
  return status;
}
