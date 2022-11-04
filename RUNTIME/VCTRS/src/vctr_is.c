#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_is.h"

extern vctr_rs_hmap_t g_vctr_hmap[Q_MAX_NUM_TABLESPACES];

int
vctr_is(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    bool *ptr_is_found,
    uint32_t *ptr_where_found
    )
{
  int status = 0;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, ptr_is_found, 
      ptr_where_found);
BYE:
  return status;
}
