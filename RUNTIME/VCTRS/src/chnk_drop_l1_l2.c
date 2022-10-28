#include "q_incs.h"
#include "q_macros.h"

#include "chnk_rs_hmap_struct.h"
#include "rs_mmap.h"
#include "isfile.h"
#include "l2_file_name.h"
#include "chnk_drop_l1_l2.h"
#include "mod_mem_used.h"

int  
chnk_drop_l1_l2(
    chnk_rs_hmap_key_t *ptr_chnk_key,
    chnk_rs_hmap_val_t *ptr_chnk_val,
    int level
    )
{
  int status = 0;
  char *l2_file = NULL; 

  if ( !( ( level == 1 ) || ( level == 2 ) ) ) { go_BYE(-1); }
  switch ( level ) { 
    case 1 : 
      if ( ptr_chnk_val->l1_mem == NULL ) { goto BYE; } // nothing to do 
      // Verify that backup exists in l2 before dropping l1 
      l2_file = l2_file_name(ptr_chnk_key->vctr_uqid, 
          ptr_chnk_key->chnk_idx);
      if ( l2_file == NULL )  { go_BYE(-1); }
      if ( !isfile(l2_file) ) { goto BYE; } // cannot delete 
      //-------------------------
      free_if_non_null(ptr_chnk_val->l1_mem);
      decr_mem_used(ptr_chnk_val->size);
      break;
      //-----------------
    case 2 : 
      // cannot delete l2 if l1 does not exist 
      if ( ptr_chnk_val->l1_mem == NULL ) { goto BYE; } // nothing to do 
      //--------------------
      l2_file = l2_file_name(ptr_chnk_key->vctr_uqid, 
          ptr_chnk_key->chnk_idx);
      if ( l2_file == NULL )  { go_BYE(-1); }
      if ( !isfile(l2_file) ) { goto BYE; } // nothing to do 
      unlink(l2_file); 
      ptr_chnk_val->l2_exists = false; 
      decr_dsk_used(ptr_chnk_val->size);
      break;
      //-----------------
    default : 
      go_BYE(-1);
      break;
  }
BYE:
  free_if_non_null(l2_file);
  return status; 
}
