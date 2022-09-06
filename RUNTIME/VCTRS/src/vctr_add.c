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
    uint32_t in_chnk_size,
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

  uint32_t chnk_size = in_chnk_size;
  if  ( chnk_size == 0 ) { 
    chnk_size = Q_VCTR_CHNK_SIZE;
  }
  vctr_rs_hmap_val_t val = 
    { .qtype = qtype, .chnk_size = chnk_size, 
      .width = width, .num_chunks = 0  } ;
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
