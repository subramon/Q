#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_is.h"
#include "vctr_persist.h"

extern vctr_rs_hmap_t g_vctr_hmap[Q_MAX_NUM_TABLESPACES];

int
vctr_persist(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    bool bval
    )
{
  int status = 0;
  if ( tbsp != 0 ) { go_BYE(-1); } 
  bool is_found; uint32_t where_found;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { go_BYE(-1); }
  if ( val.is_trash ) { go_BYE(-1); }
  // This is okay: if ( val.is_persist ) { go_BYE(-1); }
  g_vctr_hmap[tbsp].bkts[where_found].val.is_persist = bval;
BYE:
  return status;
}
