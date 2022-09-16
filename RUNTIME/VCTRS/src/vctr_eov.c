#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_is.h"
#include "vctr_eov.h"

extern vctr_rs_hmap_t g_vctr_hmap;

int
vctr_eov(
    uint32_t vctr_uqid
    )
{
  int status = 0;
  bool is_found; uint32_t where_found;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap.get(&g_vctr_hmap, &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { go_BYE(-1); }
  if ( val.is_trash ) { go_BYE(-1); }
  // TODO P3 Consider why to comment this: if ( val.is_eov ) { go_BYE(-1); }
  g_vctr_hmap.bkts[where_found].val.is_eov = true; 
BYE:
  return status;
}
