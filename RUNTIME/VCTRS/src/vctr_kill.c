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
vctr_set_num_lives_kill(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    int num_lives_kill
    )
{
  int status = 0;
  // nothing to do for vectors in other tablespaces
  if ( tbsp != 0 ) { goto BYE; } 
  if ( num_lives_kill <=  0 ) { go_BYE(-1); } 
  if ( num_lives_kill >= 16 ) { go_BYE(-1); } // some reasonable limit
  bool is_found; uint32_t where_found = ~0;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { go_BYE(-1); }
  if ( val.num_elements > 0 ) { go_BYE(-1); }
  if ( val.is_persist ) { go_BYE(-1); }
  // TODO THINK P3 if ( val.is_early_freeable ) { go_BYE(-1); }
  // I used to have the is_eov check but I think it is not necessary
  // if ( val.is_eov ) { go_BYE(-1); }
  // This is okay: if ( val.is_early_freeable ) { go_BYE(-1); }
  g_vctr_hmap[tbsp].bkts[where_found].val.is_killable = true;
  g_vctr_hmap[tbsp].bkts[where_found].val.num_lives_kill = num_lives_kill;
BYE:
  return status;
}

int 
vctr_get_num_lives_kill(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    bool *ptr_is_killable,
    int *ptr_num_lives_kill
    )
{
  int status = 0;
  if ( tbsp != 0 ) { goto BYE; } 
  bool is_found; uint32_t where_found = ~0;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { goto BYE; } 
  *ptr_is_killable = val.is_killable;
  *ptr_num_lives_kill = val.num_lives_kill;
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
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { return -1; } // TODO P2 Should we be silent here?
  if ( !val.is_killable ) { goto BYE; } // silent exit
  // fprintf(stderr, "Vector [%u:%s] killed \n", vctr_uqid, val.name);
  if ( val.num_lives_kill > 0 ) {
    g_vctr_hmap[tbsp].bkts[where_found].val.num_lives_kill--;
  }
  if ( g_vctr_hmap[tbsp].bkts[where_found].val.num_lives_kill > 0 ) { 
    /*
    printf("Vector %s lives to fight another day %d \n",
      g_vctr_hmap[tbsp].bkts[where_found].val.name, 
      g_vctr_hmap[tbsp].bkts[where_found].val.num_lives_kill);
      */
    goto BYE;  // lost one life but not ready to die
  }
  /*
  printf("Vector %s dying because of kill \n", 
    g_vctr_hmap[tbsp].bkts[where_found].val.name);
    */
  status = vctr_del(tbsp, vctr_uqid, &is_found); 
  if ( !is_found ) { go_BYE(-1); } 
BYE:
  return status;
}
