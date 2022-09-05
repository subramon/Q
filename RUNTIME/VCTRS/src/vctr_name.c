#include "q_incs.h"
#include "qtypes.h"
#include "vctr_new_uqid.h"
#include "vctr_name.h"

#include "vctr_rs_hmap_struct.h"

extern vctr_rs_hmap_t g_vctr_hmap;

int
vctr_set_name(
    uint32_t uqid,
    const char * const name
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
  vctr_rs_hmap_bkt_t *bkts = (vctr_rs_hmap_bkt_t *)g_vctr_hmap.bkts;
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
  vctr_rs_hmap_bkt_t *bkts = (vctr_rs_hmap_bkt_t *)g_vctr_hmap.bkts;
  return bkts[where].val.name;
BYE:
  return NULL;
}
