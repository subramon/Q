#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_get.h"
#include "vctr_is.h"
#include "vctr_persist.h"

extern vctr_rs_hmap_t *g_vctr_hmap;

// persist means that when we delete this vector, we keep information
// on disk that allows us to rehydrate it 
int
vctr_persist(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    bool bval
    )
{
  int status = 0;
  // nothing to do for vectors in other tablespaces
  if ( tbsp != 0 ) { goto BYE; } 
  bool is_found; uint32_t where_found = ~0;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = vctr_rs_hmap_get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { go_BYE(-1); }
  if ( val.is_error ) { go_BYE(-1); }
  // idempontent if ( val.is_persist ) { go_BYE(-1); }
  if ( val.is_killable ) { go_BYE(-1); } 
  if ( val.is_early_freeable ) { go_BYE(-1); } 
  if ( val.is_memo ) { go_BYE(-1); } 
  g_vctr_hmap[tbsp].bkts[where_found].val.is_persist = bval;
BYE:
  return status;
}
