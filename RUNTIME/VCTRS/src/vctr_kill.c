#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_is.h"
#include "vctr_del.h"
#include "vctr_kill.h"

extern vctr_rs_hmap_t *g_vctr_hmap;

// once a vector has been marked killable, you cannot undo it 
int
vctr_killable(
    uint32_t tbsp,
    uint32_t vctr_uqid
    )
{
  int status = 0;
  // nothing to do for vectors in other tablespaces
  if ( tbsp != 0 ) { goto BYE; } 
  bool is_found; uint32_t where_found = ~0;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { go_BYE(-1); }
  if ( val.is_killable ) { goto BYE; } // nothing to do 
  if ( val.is_trash ) { go_BYE(-1); }
  if ( val.is_eov ) { go_BYE(-1); }
  if ( val.is_early_free ) { go_BYE(-1); }
  if ( val.is_early_free ) { go_BYE(-1); }
  g_vctr_hmap[tbsp].bkts[where_found].val.is_killable = true; 
BYE:
  return status;
}

int 
vctr_is_killable(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    bool *ptr_bval 
    )
{
  int status = 0;
  *ptr_bval = false; 
  if ( tbsp != 0 ) { goto BYE; } 
  bool is_found; uint32_t where_found = ~0;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { goto BYE; } 
  *ptr_bval = val.is_killable;
BYE:
  return status;
}
int
vctr_kill(
    uint32_t tbsp,
    uint32_t vctr_uqid
    )
{
  int status = 0;
  if ( tbsp != 0 ) { go_BYE(-1); } 
  bool is_found; uint32_t where_found = ~0;
  vctr_rs_hmap_key_t key; memset(&key, 0, sizeof(vctr_rs_hmap_key_t));
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { return -1; } // TODO P2 Should we be silent here?
  if ( !val.is_killable ) { goto BYE; } // silent exit
  status = vctr_del(tbsp, vctr_uqid, &is_found); 
  if ( !is_found ) { go_BYE(-1); } 
BYE:
  return status;
}
