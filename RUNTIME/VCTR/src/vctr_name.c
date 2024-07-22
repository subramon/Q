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
int
vctr_set_name(
    uint32_t tbsp,
    uint32_t uqid,
    const char * const name
    )
{
  int status = 0;
  bool is_found; uint32_t where;
  if ( strlen(name) > MAX_LEN_VCTR_NAME ) { go_BYE(-1); }
  vctr_rs_hmap_key_t key = uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = vctr_rs_hmap_get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where);
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  vctr_rs_hmap_bkt_t *bkts = (vctr_rs_hmap_bkt_t *)g_vctr_hmap[tbsp].bkts;
  strcpy(bkts[where].val.name, name);

BYE:
  return status;
}

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
int
vctr_set_error(
    uint32_t tbsp,
    uint32_t uqid
    )
{
  int status = 0;
  bool is_found; uint32_t where;

  vctr_rs_hmap_key_t key = uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = vctr_rs_hmap_get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where);
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  g_vctr_hmap[tbsp].bkts[where].val.is_err = true;

BYE:
  return status;
}

int
vctr_is_error(
    uint32_t tbsp,
    uint32_t uqid,
    bool *ptr_is_err
    )
{
  int status = 0;
  bool is_found; uint32_t where;

  vctr_rs_hmap_key_t key = uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = vctr_rs_hmap_get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where);
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  *ptr_is_err = g_vctr_hmap[tbsp].bkts[where].val.is_err;

BYE:
  return status;
}
