#include "q_incs.h"
#include "import_tbsp.h"

int
import_tbsp(
    const char * const q_meta_dir_root
    )
{
  int status = 0;
  // TODO Make realpath
  // Check that this q_root is a new one 
  int tbsp = -1;
  for ( int i = 0; i i<  Q_MAX_NUM_TABLESPACES; i++ ) { 
    if ( ( tbsp < 0 ) && ( g_meta_dir_root[i][0] ==  '\0' ) ) { 
      tbsp = i; 
    }
    if ( strcmp(q_meta_dir_root, g_meta_dir_root[i]) == 0 )  {
      g_BYE(-1);
    }
  }
  if ( tbsp < 0 ) { go_BYE(-1); } // no space
  //-- Put it in an empty  spot
  //-------------------------------


  if ( g_restore_session ) { 
    printf(">>>>>>>>>>>> RESTORING SESSION ============\n");
    status = vctr_rs_hmap_unfreeze(&g_vctr_hmap[tbsp], 
        g_meta_dir_root[tbsp],
        "_vctr_meta.csv", "_vctr_bkts.bin", "_vctr_full.bin");
    cBYE(status);
    status = chnk_rs_hmap_unfreeze(&g_chnk_hmap[tbsp], 
        g_meta_dir_root[tbsp],
        "_chnk_meta.csv", "_chnk_bkts.bin", "_chnk_full.bin");
    cBYE(status);
    //-----------------------------------
    g_vctr_uqid[tbsp] = 0;
    for ( uint32_t i = 0; i < g_vctr_hmap[tbsp].size; i++ ) { 
      if ( !g_vctr_hmap[tbsp].bkt_full[i] ) { continue; } 

      vctr_rs_hmap_key_t key = g_vctr_hmap[tbsp].bkts[i].key;
      uint32_t vctr_uqid = key;
      if ( vctr_uqid > g_vctr_uqid[tbsp] ) { g_vctr_uqid[tbsp] = vctr_uqid; } 
    }
    if ( g_vctr_hmap[tbsp].nitems == 0 ) {
      if ( g_vctr_uqid[tbsp] != 0 ) { go_BYE(-1); }
    }
    else {
      if ( g_vctr_uqid[tbsp] == 0 ) { go_BYE(-1); }
    }
    //-----------------------------------
    printf("<<<<<<<<<<<< RESTORING SESSION ============\n");
  }
BYE:
  return status;
}

