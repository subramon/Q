#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_get.h"
#include "l2_file_name.h"
#include "get_file_size.h"
#include "vctr_new_uqid.h"
#include "vctr_name.h"

#include "vctr_rs_hmap_struct.h"

extern vctr_rs_hmap_t *g_vctr_hmap;

char *
vctr_file_info(
    uint32_t tbsp,
    uint32_t uqid,
    int64_t *ptr_file_size
    )
{
  int status = 0;
  bool is_found; uint32_t where;
  char *lma_file = NULL; 
  vctr_rs_hmap_key_t key = uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = vctr_rs_hmap_get(&g_vctr_hmap[tbsp], &key, &val, &is_found, &where);
  cBYE(status);
  if ( !is_found ) { return NULL; } 
  lma_file = l2_file_name(tbsp, uqid,  ((uint32_t)~0));
  *ptr_file_size = get_file_size(lma_file);
  return lma_file; 
BYE:
  return NULL;
}
