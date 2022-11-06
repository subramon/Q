#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_is.h"
#include "vctr_width.h"

extern vctr_rs_hmap_t g_vctr_hmap[Q_MAX_NUM_TABLESPACES];

int
vctr_width(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t *ptr_width
    )
{
  int status = 0;
  bool is_found; uint32_t where_found;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { go_BYE(-1); }
  *ptr_width = val.width;
BYE:
  return status;
}
