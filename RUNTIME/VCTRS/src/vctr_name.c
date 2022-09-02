#include "q_incs.h"
#include "qtypes.h"
#include "vctr_new_uqid.h"
#include "vctr_name.h"

#include "vctr_rs_hmap_struct.h"
#include "../../../TMPL_FIX_HASHMAP/VCTR_HMAP/inc/rs_hmap_get.h"

extern vctr_rs_hmap_t g_vctr_hmap;

int
vctr_set_name(
    const char * const name,
    uint32_t uqid
    )
{
  int status = 0;
  bool is_found; uint32_t where;
  if ( strlen(name) > MAX_LEN_VCTR_NAME ) { go_BYE(-1); }
  vctr_rs_hmap_key_t key = uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap.get(&g_vctr_hmap, &key, &val, &is_found, 
      &where);
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  if ( val.is_trash    ) { go_BYE(-1); }
  bkt_t *bkts = (bkt_t *)g_vctr_hmap.bkts;
  strcpy(bkts[where].val.name, name);

BYE:
  return status;
}

char *
vctr_get_name(
    uint32_t uqid
    )
{
  int status = 0;
  bool is_found; uint32_t where;
  vctr_rs_hmap_key_t key = uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap.get(&g_vctr_hmap, &key, &val, &is_found, &where);
  cBYE(status);
  if ( !is_found ) { return NULL; } 
  if ( val.is_trash ) { return NULL; } 
  bkt_t *bkts = (bkt_t *)g_vctr_hmap.bkts;
  return bkts[where].val.name;
BYE:
  return NULL;
}
