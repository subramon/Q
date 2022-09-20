#include "q_incs.h"
#include "qtypes.h"
#include "vctr_consts.h"
#include "vctr_new_uqid.h"
#include "vctr_is.h"
#include "vctr_cnt.h"
#include "vctr_add.h"

#include "vctr_rs_hmap_struct.h"

extern vctr_rs_hmap_t g_vctr_hmap;

int
vctr_add1(
    qtype_t qtype,
    uint32_t width,
    uint32_t in_max_num_in_chnk,
    int memo_len,
    uint32_t *ptr_uqid
    )
{
  int status = 0;
  uint32_t old_vctr_cnt, new_vctr_cnt;
  old_vctr_cnt = vctr_cnt();
  if ( ( qtype == Q0 ) || ( qtype >= NUM_QTYPES ) ) { go_BYE(-1); }
  *ptr_uqid = vctr_new_uqid();
  vctr_rs_hmap_key_t key = *ptr_uqid; 
  if ( width == 0 ) { 
    int w = get_width_c_qtype(qtype);
    if ( w <= 0 ) { go_BYE(-1); }
    width = w;
  }
  if ( width == 0 ) { go_BYE(-1); }

  uint32_t max_num_in_chnk = in_max_num_in_chnk;
  if  ( max_num_in_chnk == 0 ) { 
    max_num_in_chnk = Q_VCTR_MAX_NUM_IN_CHNK;
  }
  vctr_rs_hmap_val_t val = 
    { .qtype = qtype, .max_num_in_chnk = max_num_in_chnk, 
      .memo_len = memo_len, .width = width, .num_chnks = 0,
      .ref_count = 1 } ;
  status = g_vctr_hmap.put(&g_vctr_hmap, &key, &val); cBYE(status);
#ifdef DEBUG
  new_vctr_cnt = vctr_cnt();
  if ( new_vctr_cnt != old_vctr_cnt + 1 ) { go_BYE(-1); }
  // initializations below for debugging. Not needed
  bool is_found = true; uint32_t where_found = 123456789;
  status = vctr_is(*ptr_uqid, &is_found, &where_found); 
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
#endif
BYE:
  return status;
}
