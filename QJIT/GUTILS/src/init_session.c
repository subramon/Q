#include <pthread.h>
#include "q_incs.h"
#include "q_macros.h"
#include "rmtree.h"

#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_instantiate.h"
#include "vctr_rs_hmap_unfreeze.h"

#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_instantiate.h"
#include "chnk_rs_hmap_unfreeze.h"

#include "vctr_usage.h"
#include "web_struct.h"
#include "mem_mgr_struct.h"

#include "mod_mem_used.h"
#include "webserver.h"
#include "mem_mgr.h"
#undef MAIN_PGM
#include "qjit_globals.h"
#include "init_session.h"

int
init_session(
    void
    )
{
  int status = 0;
  // For webserver 
  if ( g_is_webserver ) {  
    g_web_info.is_out_of_band = false;
    status = pthread_create(&g_webserver, NULL, &webserver, &g_web_info);
    cBYE(status);
  }
  // For out of band 
  if ( g_is_out_of_band ) {  
    g_out_of_band_info.is_out_of_band = true;
    status = pthread_create(&g_out_of_band, NULL, &webserver, 
        &g_out_of_band_info);
    cBYE(status);
  }
  // For memory manager
  if ( g_is_mem_mgr ) { 
    pthread_cond_init(&g_mem_cond, NULL);
    pthread_mutex_init(&g_mem_mutex, NULL);
    g_mutex_created = true;

    g_mem_mgr_info.dummy = 123456789;
    status = pthread_create(&g_mem_mgr, NULL, &mem_mgr, &g_mem_mgr_info);
    cBYE(status);
    pthread_cond_signal(&g_mem_cond);
  }
  int tbsp = 0;  // init_session() only for primary tablespace

  // START For hashmaps  for vector, ...
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
    g_vctr_uqid = 0;
    for ( uint32_t i = 0; i < g_vctr_hmap[tbsp].size; i++ ) { 
      if ( !g_vctr_hmap[tbsp].bkt_full[i] ) { continue; } 

      vctr_rs_hmap_key_t key = g_vctr_hmap[tbsp].bkts[i].key;
      uint32_t vctr_uqid = key;
      if ( vctr_uqid > g_vctr_uqid ) { g_vctr_uqid = vctr_uqid; } 
      //--- Set usage statistics
      uint64_t mem, dsk; 
      status = vctr_usage(tbsp, vctr_uqid, &mem, &dsk); cBYE(status);
      status = incr_dsk_used(dsk); cBYE(status);
    }
    if ( g_vctr_hmap[tbsp].nitems == 0 ) {
      if ( g_vctr_uqid != 0 ) { go_BYE(-1); }
    }
    else {
      if ( g_vctr_uqid == 0 ) { go_BYE(-1); }
    }
    //-----------------------------------
    // reset touch time 
    for ( uint32_t i = 0; i < g_chnk_hmap[tbsp].size; i++ ) { 
      g_chnk_hmap[tbsp].bkts[i].val.touch_time = 0;
    }
    printf("<<<<<<<<<<<< RESTORING SESSION ============\n");
  }
  else { 
    printf("<<<<<<<<<<<< STARTING NEW SESSION ============\n");
    g_vctr_hmap_config.so_file = strdup("libhmap_vctr.so");
    status = vctr_rs_hmap_instantiate(&g_vctr_hmap[tbsp], 
        &g_vctr_hmap_config); 
    cBYE(status);
    free_if_non_null(g_vctr_hmap_config.so_file);

    g_chnk_hmap_config.so_file = strdup("libhmap_chnk.so"); 
    status = chnk_rs_hmap_instantiate(&g_chnk_hmap[tbsp], 
        &g_chnk_hmap_config); 
    cBYE(status);
    free_if_non_null(g_chnk_hmap_config.so_file);

    rmtree(g_data_dir_root[tbsp]);
    rmtree(g_meta_dir_root);
    status = mkdir(g_data_dir_root[tbsp], 0744); cBYE(status);
    status = mkdir(g_meta_dir_root, 0744); cBYE(status);
    printf("<<<<<<<<<<<< STARTED  NEW SESSION ============\n");
  }


  // STOP  For hashmaps  for vector, ...
BYE:
  return status;
}
