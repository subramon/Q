#include <pthread.h>
#include "q_incs.h"
#include "q_macros.h"
#include "rmtree.h"
#include "isfile_in_dir.h"

#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_instantiate.h"
#include "vctr_rs_hmap_unfreeze.h"

#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_instantiate.h"
#include "chnk_rs_hmap_unfreeze.h"

#include "vctr_usage.h"
#include "vctr_del.h"
#include "web_struct.h"

#include "mod_mem_used.h"
#include "webserver.h"
#undef MAIN_PGM
#include "qjit_globals.h"
#include "clean_hmap.h"
#include "init_session.h"

int
init_session(
    void
    )
{
  int status = 0;
  // For webserver 
  if ( g_is_webserver ) {  
    printf("Spawned webserver\n");
    g_web_info.is_external = true;
    status = pthread_create(&g_webserver, NULL, &webserver, &g_web_info);
    cBYE(status);
  }
  // For out of band 
  if ( g_is_out_of_band ) {  
    printf("Spawned out-of-band server\n");
    g_out_of_band_info.is_external = false;
    status = pthread_create(&g_out_of_band, NULL, &webserver, 
        &g_out_of_band_info);
    cBYE(status);
  }
  int tbsp = 0;  // init_session() only for primary tablespace

  // START For hashmaps  for vector, ...
  // If we are asked to restore a session but we don't have the 
  // relevant files, then we assume that a new session needs
  // to be created
  if ( g_restore_session ) {
    bool mk_new_session = false;
    if ( !isfile_in_dir("_vctr_meta.csv", g_meta_dir_root) ) {
      mk_new_session = true;
    }
    if ( !isfile_in_dir("_vctr_bkts.bin", g_meta_dir_root) ) {
      mk_new_session = true;
    }
    if ( !isfile_in_dir("_vctr_full.bin", g_meta_dir_root) ) {
      mk_new_session = true;
    }
    if ( mk_new_session ) {
      g_restore_session = false;
    }
  }
  if ( g_restore_session ) {
    printf(">>>>>>>>>>>> RESTORING SESSION ============\n");
    status = vctr_rs_hmap_unfreeze(&g_vctr_hmap[tbsp], 
        g_meta_dir_root,
        "_vctr_meta.csv", "_vctr_bkts.bin", "_vctr_full.bin");
    cBYE(status);
    status = chnk_rs_hmap_unfreeze(&g_chnk_hmap[tbsp], 
        g_meta_dir_root,
        "_chnk_meta.csv", "_chnk_bkts.bin", "_chnk_full.bin");
    cBYE(status);
    //-----------------------------------
    // reset chunk info. Do this before vctr_usage() is called
    // since we want l1_mem to be 0 
    for ( uint32_t i = 0; i < g_chnk_hmap[tbsp].size; i++ ) { 
      g_chnk_hmap[tbsp].bkts[i].val.touch_time = 0;
      g_chnk_hmap[tbsp].bkts[i].val.l1_mem = NULL;
      g_chnk_hmap[tbsp].bkts[i].val.num_readers = 0;
      g_chnk_hmap[tbsp].bkts[i].val.num_writers = 0;
    }
    //-----------------------------------
    g_vctr_uqid = 0;
    int num_to_delete = 0;
    status = clean_hmap(&(g_vctr_hmap[tbsp]), &(g_chnk_hmap[tbsp]), 
        tbsp, &num_to_delete ); 
    cBYE(status);
    //-------------------
    if ( tbsp == 0 ) { 
      for ( uint32_t i = 0; i < g_vctr_hmap[tbsp].size; i++ ) { 
        if ( !g_vctr_hmap[tbsp].bkt_full[i] ) { continue; } 
        vctr_rs_hmap_key_t vctr_uqid = g_vctr_hmap[tbsp].bkts[i].key;
        if ( vctr_uqid > g_vctr_uqid ) { g_vctr_uqid = vctr_uqid; } 
        //--- Set usage statistics
        uint64_t mem, dsk; 
        status = vctr_usage(tbsp, vctr_uqid, &mem, &dsk); cBYE(status);
        if ( mem != 0 ) { go_BYE(-1); } // cannot have mem at this stage
        if ( dsk == 0 ) { go_BYE(-1); } // must have   dsk at this stage
        status = incr_dsk_used(dsk); cBYE(status);
      }
      if ( num_to_delete == 0 ) { 
        // Can't do following if we delete vectors in above loop
        if ( g_vctr_hmap[tbsp].nitems == 0 ) {
          if ( g_vctr_uqid != 0 ) { go_BYE(-1); }
        }
        else {
          if ( g_vctr_uqid == 0 ) { go_BYE(-1); }
        }
      }
    }
    //-----------------------------------
    printf("<<<<<<<<<<<< RESTORING SESSION ============\n");
  }
  else { 
    printf("<<<<<<<<<<<< STARTING NEW SESSION ============\n");
    status = vctr_rs_hmap_instantiate(&g_vctr_hmap[tbsp], 
        &g_vctr_hmap_config); 
    cBYE(status);

    status = chnk_rs_hmap_instantiate(&g_chnk_hmap[tbsp], 
        &g_chnk_hmap_config); 
    cBYE(status);

    rmtree(g_data_dir_root[tbsp]);
    rmtree(g_meta_dir_root);
    status = mkdir(g_data_dir_root[tbsp], 0744); cBYE(status);
    if ( !isdir(g_data_dir_root[tbsp]) ) { go_BYE(-1); }
    if ( !isdir(g_meta_dir_root) ) { go_BYE(-1); }
    printf("<<<<<<<<<<<< STARTED  NEW SESSION ============\n");
  }


  // STOP  For hashmaps  for vector, ...
BYE:
  return status;
}
