#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_put_chunk.h"

extern vctr_rs_hmap_t g_vctr_hmap;

int
vctr_put_chunk(
    uint32_t uqid,
    void *X,
    int n // number of elements
    )
{
  int status = 0;

  vctr_rs_hmap_key_t key = uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap.get(&g_vctr_hmap, &key, &val, &is_found, 
      &where);
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  if ( val.is_trash  ) { go_BYE(-1); }
  if ( val.is_eov    ) { go_BYE(-1); }
BYE:
  return status;
}
