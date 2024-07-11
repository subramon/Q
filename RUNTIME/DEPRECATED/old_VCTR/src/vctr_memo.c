#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_is.h"
#include "vctr_memo.h"

extern vctr_rs_hmap_t *g_vctr_hmap;

int
vctr_set_memo(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    int memo_len
    )
{
  int status = 0;
  bool is_found; uint32_t where_found = ~0;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { go_BYE(-1); }
  // once vector has elements in it, cannot modify its memo len 
  if ( val.num_elements > 0 ) { go_BYE(-1); } 
  if ( val.is_persist ) { go_BYE(-1); } 
  //--------------------------
  g_vctr_hmap[tbsp].bkts[where_found].val.memo_len = memo_len;
BYE:
  return status;
}

int
vctr_get_memo_len(
    uint32_t tbsp,
    uint32_t uqid,
    int *ptr_memo_len
    )
{
  int status = 0;
  bool is_found; uint32_t where;
  vctr_rs_hmap_key_t key = uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, &where);
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  vctr_rs_hmap_bkt_t *bkts = (vctr_rs_hmap_bkt_t *)g_vctr_hmap[tbsp].bkts;
  *ptr_memo_len = bkts[where].val.memo_len;
BYE:
  return status;
}

int
vctr_cast(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    const char * const str_qtype
    )
{
  int status = 0;
  bool is_found; uint32_t where_found = ~0;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { go_BYE(-1); }
  qtype_t old_qtype = val.qtype;
  qtype_t new_qtype = get_c_qtype(str_qtype);
  switch ( old_qtype ) { 
    case BL: case I1 : case UI1 :  
      switch ( new_qtype ) { 
        case BL : case I1 : case UI1 : break;
        default : go_BYE(-1); break;
      }
      break;
    case I2 : case UI2 : case F2 : 
      switch ( new_qtype ) { 
        case I2 : case UI2 : case F2 : break;
        default : go_BYE(-1); break;
      }
      break;
    case I8 : case F8 : case UI8 : break;
      switch ( new_qtype ) { 
        case I8 : case F8 : case UI8 : break;
        default : go_BYE(-1); break;
      }
      break;
    case I4 : case F4 : case UI4 : break;
      switch ( new_qtype ) { 
        case I4 : case F4 : case UI4 : break;
        default : go_BYE(-1); break;
      }
      break;
    default :
      fprintf(stderr, "Cannot cast from %s to %s \n", 
          get_str_qtype(old_qtype), str_qtype);
      go_BYE(-1);
      break;
  }
  // make sure nobody is reading it 
  if ( val.num_writers > 0 ) { go_BYE(-1); } 
  if ( val.num_readers > 0 ) { go_BYE(-1); } 
  if ( val.is_eov == false ) { go_BYE(-1); } 
  // TODO P1 Make sure no readers/writers for chunks if any 
  //--------------------------
  g_vctr_hmap[tbsp].bkts[where_found].val.qtype = new_qtype;
BYE:
  return status;
}

