#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_get.h"
#include "vctr_is.h"
#include "vctr_meta.h"

extern vctr_rs_hmap_t *g_vctr_hmap;

// Centralized location for all kinds of meta-data 
int
vctr_meta(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    const char  * const meta,
    bool *ptr_bl,
    int64_t *ptr_i64,
    int64_t *ptr_i32
    )
{
  int status = 0;
  bool is_found; uint32_t where_found = ~0;
  if ( meta == NULL ) { go_BYE(-1); }

  *ptr_bl = false;
  *ptr_i64 = 0;
  *ptr_i32 = 0;

  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = vctr_rs_hmap_get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { go_BYE(-1); }
  if ( strcmp(meta, "is_persist") == 0 ) { 
    *ptr_bl = val.is_persist;
  }
  else {
    go_BYE(-1);
  }
BYE:
  return status;
}
