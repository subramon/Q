#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_put.h"
#include "vctr_consts.h"
#include "vctr_new_uqid.h"
#include "vctr_is.h"
#include "vctr_cnt.h"
#include "vctr_add.h"

#include "vctr_rs_hmap_struct.h"

extern vctr_rs_hmap_t *g_vctr_hmap;

int
vctr_add(
    qtype_t qtype,
    uint32_t width,
    uint32_t max_num_in_chnk,
    bool is_memo,
    int memo_len,
    bool is_killable,
    int num_kill_ignore,
    bool is_early_freeable,
    int num_free_ignore,
    uint32_t *ptr_uqid
    )
{
  int status = 0;
  uint32_t tbsp =  0; // cannot add to a different tablespace => tbsp = 0
#ifdef DEBUG
  uint32_t old_vctr_cnt, new_vctr_cnt;
  old_vctr_cnt = vctr_cnt(tbsp);
#endif
  if ( ( qtype == Q0 ) || ( qtype >= QF ) ) { go_BYE(-1); }
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
  if ( is_memo ) { 
    if ( memo_len <= 0 ) { go_BYE(-1); } 
  }
  else {
    if ( memo_len != 0 ) { go_BYE(-1); } 
  }
  //----------------------------------------------
  if ( num_kill_ignore < 0 ) { go_BYE(-1); } 
  if ( num_kill_ignore > 16 ) { go_BYE(-1); } 
  if ( !is_killable ) { if ( num_kill_ignore != 0 ) { go_BYE(-1); }  }
  //----------------------------------------------
  if ( num_free_ignore < 0 ) { go_BYE(-1); } 
  if ( num_free_ignore > 16 ) { go_BYE(-1); } 
  if ( !is_early_freeable ) { if ( num_free_ignore != 0 ) { go_BYE(-1); }  }
  //----------------------------------------------
  if ( is_memo && is_early_freeable  ) { go_BYE(-1); } 
  //----------------------------------------------
  if  ( max_num_in_chnk == 0 ) { 
    max_num_in_chnk = Q_VCTR_MAX_NUM_IN_CHNK;
  }
  if (((max_num_in_chnk/64)*64) != max_num_in_chnk ) { go_BYE(-1); }
  // Unfortunate special case for B1, SC
  if ( qtype == SC ) { 
    if ( width < 2 ) { go_BYE(-1); }
  }
  else if ( qtype == B1 ) {
    // no check 
  }
  else {
    if ( width == 0 ) { go_BYE(-1); }
  }
  //-------------------------------------------
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(val));
  val.qtype = qtype;
  val.max_num_in_chnk = max_num_in_chnk;
  val.is_memo = is_memo; 
  val.memo_len = memo_len;
  val.is_killable = is_killable; 
  val.num_kill_ignore = num_kill_ignore;
  val.is_early_freeable = is_early_freeable; 
  val.num_free_ignore = num_free_ignore;
  val.width = width;

  status = vctr_rs_hmap_put(&(g_vctr_hmap[tbsp]), &key, &val); cBYE(status);
#ifdef DEBUG
  new_vctr_cnt = vctr_cnt(tbsp);
  if ( new_vctr_cnt != old_vctr_cnt + 1 ) { go_BYE(-1); }
  bool is_found = true; uint32_t where_found = ~0;
  status = vctr_is(tbsp, *ptr_uqid, &is_found, &where_found); 
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
#endif
BYE:
  return status;
}
