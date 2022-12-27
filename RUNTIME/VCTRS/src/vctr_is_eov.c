#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_is.h"
#include "vctr_is_eov.h"

extern vctr_rs_hmap_t g_vctr_hmap[Q_MAX_NUM_TABLESPACES];
int
vctr_is_eov(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    bool *ptr_is_eov
    )
{
  int status = 0;
  bool is_found; uint32_t where_found = ~0;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap, &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { go_BYE(-1); }
  *ptr_is_eov = val.is_eov;
BYE:
  return status;
}

int
vctr_is_lma(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    bool *ptr_is_lma
    )
{
  int status = 0;
  bool is_found; uint32_t where_found = ~0;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap, &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { go_BYE(-1); }
  *ptr_is_lma = val.is_lma;
BYE:
  return status;
}
