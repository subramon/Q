#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_get.h"
#include "vctr_is.h"
#include "vctr_eov.h"

extern vctr_rs_hmap_t *g_vctr_hmap;
int
vctr_eov(
    uint32_t tbsp,
    uint32_t vctr_uqid
    )
{
  int status = 0;
  bool is_found; uint32_t where_found = ~0;
  vctr_rs_hmap_val_t *ptr_vctr_val = NULL; 

  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = vctr_rs_hmap_get(&(g_vctr_hmap[tbsp]), &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { go_BYE(-1); }
  // vctr_eoc() is idempotent operator. Hence, following has been commented
  // if ( val.is_eov ) { go_BYE(-1); }
  ptr_vctr_val = &(g_vctr_hmap[tbsp].bkts[where_found].val);
  if ( ptr_vctr_val->num_elements == 0 ) { go_BYE(-1); }
  ptr_vctr_val->is_eov = true; 
BYE:
  return status;
}
