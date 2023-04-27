#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
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
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where);
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  if ( val.is_trash    ) { go_BYE(-1); }
  vctr_rs_hmap_bkt_t *bkts = (vctr_rs_hmap_bkt_t *)g_vctr_hmap[tbsp].bkts;
  strcpy(bkts[where].val.name, name);

BYE:
  return status;
}

char *
vctr_get_name(
    uint32_t tbsp,
    uint32_t uqid
    )
{
  int status = 0;
  bool is_found; uint32_t where;
  vctr_rs_hmap_key_t key = uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, &where);
  cBYE(status);
  if ( !is_found ) { return NULL; } 
  if ( val.is_trash ) { return NULL; } 
  vctr_rs_hmap_bkt_t *bkts = (vctr_rs_hmap_bkt_t *)g_vctr_hmap[tbsp].bkts;
  return bkts[where].val.name;
BYE:
  return NULL;
}
int
vctr_get_max_num_in_chunk(
    uint32_t tbsp,
    uint32_t uqid,
    uint32_t *ptr_max_num_in_chunk
    )
{
  int status = 0;
  bool is_found; uint32_t where;
  vctr_rs_hmap_key_t key = uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, &where);
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); } 
  if ( val.is_trash ) { go_BYE(-1); } 
  vctr_rs_hmap_bkt_t *bkts = (vctr_rs_hmap_bkt_t *)g_vctr_hmap[tbsp].bkts;
  *ptr_max_num_in_chunk = bkts[where].val.max_num_in_chnk;
BYE:
  return status;
}

int
vctr_get_qtype(
    uint32_t tbsp,
    uint32_t uqid,
    qtype_t *ptr_qtype
    )
{
  int status = 0;
  bool is_found; uint32_t where;
  vctr_rs_hmap_key_t key = uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, &where);
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  if ( val.is_trash ) { go_BYE(-1); }
  vctr_rs_hmap_bkt_t *bkts = (vctr_rs_hmap_bkt_t *)g_vctr_hmap[tbsp].bkts;
  *ptr_qtype = bkts[where].val.qtype;
BYE:
  return status;
}

int
vctr_get_ref_count(
    uint32_t tbsp,
    uint32_t uqid,
    int *ptr_ref_count
    )
{
  int status = 0;
  bool is_found; uint32_t where;
  vctr_rs_hmap_key_t key = uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, &where);
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  if ( val.is_trash ) { go_BYE(-1); }
  vctr_rs_hmap_bkt_t *bkts = (vctr_rs_hmap_bkt_t *)g_vctr_hmap[tbsp].bkts;
  *ptr_ref_count = bkts[where].val.ref_count;
BYE:
  return status;
}

