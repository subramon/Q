#include "q_incs.h"
#include "qtypes.h"
#include "vctr_new_uqid.h"
#include "vctr_add.h"
#include "vctr_cnt.h"
#include "chnk_cnt.h"
#include "chnk_is.h"

#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"

extern vctr_rs_hmap_t g_vctr_hmap;
extern chnk_rs_hmap_t g_chnk_hmap;

int
vctr_add1(
    qtype_t qtype,
    uint32_t *ptr_uqid
    )
{
  int status = 0;
  uint32_t old_vctr_cnt, old_chnk_cnt = 0;
  uint32_t new_vctr_cnt, new_chnk_cnt = 0;
  old_vctr_cnt = vctr_cnt();
  old_chnk_cnt = chnk_cnt();
  if ( ( qtype == Q0 ) || ( qtype >= NUM_QTYPES ) ) { go_BYE(-1); }
  *ptr_uqid = vctr_new_uqid();
  printf("uqid = %u\n", *ptr_uqid);
  vctr_rs_hmap_key_t key = *ptr_uqid; 
  vctr_rs_hmap_val_t val = { .qtype = qtype, .num_chunks = 1  } ;
  status = g_vctr_hmap.put(&g_vctr_hmap, &key, &val); cBYE(status);
  // create one empty chunk for this vector
  chnk_rs_hmap_key_t chnk_key = { .vctr_uqid = *ptr_uqid, .chnk_idx = 0};
  chnk_rs_hmap_val_t chnk_val = { .qtype = qtype } ;
  status = g_chnk_hmap.put(&g_chnk_hmap, &chnk_key, &chnk_val); 
  cBYE(status);
#ifdef DEBUG
  new_vctr_cnt = vctr_cnt();
  if ( new_vctr_cnt != old_vctr_cnt + 1 ) { go_BYE(-1); }
  new_chnk_cnt = chnk_cnt();
  if ( new_chnk_cnt != old_chnk_cnt + 1 ) { go_BYE(-1); }
  bool is_found; uint32_t where_found;
  status = chnk_is(*ptr_uqid, 0, &is_found, &where_found); 
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
#endif
BYE:
  return status;
}
