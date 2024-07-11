#include "q_incs.h"
#include "qtypes.h"
#include "vctr_consts.h"
#include "vctr_new_uqid.h"
#include "vctr_is.h"
#include "vctr_cnt.h"
#include "vctr_add.h"

#include "vctr_rs_hmap_struct.h"

extern vctr_rs_hmap_t *g_vctr_hmap;

int
vctr_add1(
    qtype_t qtype,
    uint32_t width,
    uint32_t in_max_num_in_chnk,
    int memo_len,
    int num_lives_kill,
    int num_lives_free,
    uint32_t *ptr_uqid
    )
{
  int status = 0;
  uint32_t tbsp =  0; // cannot add to a different tablespace => tbsp = 0
#ifdef DEBUG
  uint32_t old_vctr_cnt, new_vctr_cnt;
  old_vctr_cnt = vctr_cnt(tbsp);
#endif
  if ( ( qtype == Q0 ) || ( qtype >= NUM_QTYPES ) ) { go_BYE(-1); }
  *ptr_uqid = vctr_new_uqid();
  vctr_rs_hmap_key_t key = *ptr_uqid; 
  if ( width == 0 ) { 
    width = get_width_c_qtype(qtype);
  }
#ifdef DEBUG
  {
  bool is_found; uint32_t where_found = ~0;
  status = vctr_is(tbsp, *ptr_uqid, &is_found, &where_found); cBYE(status);
  if ( is_found ) { go_BYE(-1); }
  }
#endif
  if ( num_lives_kill < 0 ) { go_BYE(-1); } 
  if ( num_lives_free < 0 ) { go_BYE(-1); } 
  if ( num_lives_kill >= 16 ) { go_BYE(-1); }  // some reasonable limit
  if ( num_lives_free >= 16 ) { go_BYE(-1); }  // some reasonable limit
  bool is_killable = false, is_early_freeable = false;
  if ( num_lives_kill > 0 ) { is_killable = true; }
  if ( num_lives_free > 0 ) { is_early_freeable = true; }

  uint32_t max_num_in_chnk = in_max_num_in_chnk;
  if  ( max_num_in_chnk == 0 ) { 
    max_num_in_chnk = Q_VCTR_MAX_NUM_IN_CHNK;
  }
  // Unfortunate special case for B1 
  if ( qtype != B1 ) {
    if ( width == 0 ) { go_BYE(-1); }
  }
  //-------------------------------------------
  vctr_rs_hmap_val_t val = 
    { .qtype = qtype, .max_num_in_chnk = max_num_in_chnk, 
      .memo_len = memo_len, .width = width, .num_chnks = 0,
      .num_lives_kill = num_lives_kill, .is_killable = is_killable, 
      .num_lives_free = num_lives_free, .is_early_freeable = is_early_freeable, 
      .ref_count = 0 } ; // TODO P1 MAKE SURE THIS IS OK. Used to be 1
  status = vctr_rs_hmap_put(&(g_vctr_hmap[tbsp]), &key, &val); cBYE(status);
#ifdef DEBUG
  new_vctr_cnt = vctr_cnt(tbsp);
  if ( new_vctr_cnt != old_vctr_cnt + 1 ) { go_BYE(-1); }
  // initializations below for debugging. Not needed
  bool is_found = true; uint32_t where_found = ~0;
  status = vctr_is(tbsp, *ptr_uqid, &is_found, &where_found); 
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
#endif
BYE:
  return status;
}
