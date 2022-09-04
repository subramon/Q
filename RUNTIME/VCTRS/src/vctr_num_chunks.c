#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_is.h"
#include "vctr_num_chunks.h"

extern vctr_rs_hmap_t g_vctr_hmap;

int
vctr_num_chunks(
    uint32_t vctr_uqid,
    uint32_t *ptr_num_chunks
    )
{
  int status = 0;
  bool is_found; uint32_t where_found;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap.get(&g_vctr_hmap, &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { go_BYE(-1); }
  *ptr_num_chunks = val.num_chunks;
BYE:
  return status;
}
