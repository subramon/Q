#include "q_incs.h"
#include "vctr_rs_hmap_key_type.h"
#include "vctr_rs_hmap_val_type.h"
#include "chnk_rs_hmap_key_type.h"
#include "chnk_rs_hmap_val_type.h"
#include "vctr_name_to_uqid.h"

#undef MAIN_PGMN
#include "qjit_globals.h"

int 
vctr_name_to_uqid(
    uint32_t tbsp,
    const char * const name,
    uint32_t *ptr_vctr_uqid,
    bool *ptr_found
    )
{
  int status = 0;
  if ( ( name == NULL ) || ( *name == '\0' ) ) { go_BYE(-1); }
  // This is a dumb sequential search. Should think up a better one 
  uint32_t vctr_uqid = 0;
  bool found = false; 
  for ( uint32_t i = 0; i < g_vctr_hmap[tbsp].size; i++ ) { 
    if ( !g_vctr_hmap[tbsp].bkt_full[i] ) { continue; } 
    if ( strcmp(g_vctr_hmap[tbsp].bkts[i].val.name, name) == 0 ) { 
      vctr_uqid = g_vctr_hmap[tbsp].bkts[i].key;
      found = true;
      break;
    }
  }
  *ptr_vctr_uqid = vctr_uqid;
  *ptr_found = found;
BYE:
  return status;
}
