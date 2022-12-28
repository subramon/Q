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

#include "web_struct.h"
#include "mem_mgr_struct.h"

#include "webserver.h"
#include "mem_mgr.h"
#include "read_configs.h"
#define MAIN_PGM
#include "qjit_globals.h"
#include "init_globals.h"

int
init_globals(
    void
    )
{
  int status = 0;
  // Initialize global variables
  g_halt = 0;
  g_webserver_interested = 0; 
  g_L_status = 0;

  for ( int i = 0; i < Q_MAX_NUM_TABLESPACES; i++ ) { 
    memset(&g_vctr_hmap[i], 0, sizeof(vctr_rs_hmap_t));
    g_vctr_uqid[i] = 0; 
    memset(&g_chnk_hmap[i], 0, sizeof(chnk_rs_hmap_t));
    memset(g_data_dir_root[i], 0, Q_MAX_LEN_DIR_NAME+1);
    memset(g_meta_dir_root[i], 0, Q_MAX_LEN_DIR_NAME+1);
    memset(g_tbsp_name[i], 0, Q_MAX_LEN_DIR_NAME+1);
  }
  strcpy(g_tbsp_name[0], "original writable tablespace");
  //------------------------
  g_mutex_created = false;

  g_mem_used    = 0;
  g_dsk_used    = 0;

  //------------------------
  memset(&g_web_info,         0, sizeof(web_info_t));
  memset(&g_out_of_band_info, 0, sizeof(web_info_t));
  memset(&g_mem_mgr_info,     0, sizeof(mem_mgr_info_t));

  memset(&g_vctr_hmap_config, 0, sizeof(rs_hmap_config_t));
  memset(&g_chnk_hmap_config, 0, sizeof(rs_hmap_config_t));

  status = read_configs(); cBYE(status);
  //------------------------
  /* Hard coding below no longer needed. These come from config file 
  g_restore_session = false;
  //-----------------------
  g_is_webserver   = false;
  g_is_out_of_band = false;
  g_is_mem_mgr     = false;
  //-----------------------
  strcpy(g_data_dir_root[0], "/home/subramon/local/Q/data/"); 
  strcpy(g_meta_dir_root[0], "/home/subramon/local/Q/meta/"); 

  g_mem_allowed = 4 * 1024 * (uint64_t)1048576 ; // in Bytes
  g_dsk_allowed = 32 * 1024 * (uint64_t)1048576 ; // in Bytes

  g_is_webserver = false;
  g_is_out_of_band = false; 
  g_is_mem_mgr  = false; 

  g_web_info.port         = 8004; 
  g_out_of_band_info.port = 8008; 

  g_vctr_hmap_config.min_size = 32;
  g_vctr_hmap_config.max_size = 0;

  g_chnk_hmap_config.min_size = 32;
  g_chnk_hmap_config.max_size = 0;
  */

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
  int tbsp = 0;  // init_globals() only for primary tablespace

  // START For hashmaps  for vector, ...
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
  else { 
    printf("<<<<<<<<<<<< STARTING NEW SESSION ============\n");
    g_vctr_hmap_config.so_file = strdup("libhmap_vctr.so"); 
    status = vctr_rs_hmap_instantiate(&g_vctr_hmap[tbsp], 
        &g_vctr_hmap_config); 
    cBYE(status);

    g_chnk_hmap_config.so_file = strdup("libhmap_chnk.so"); 
    status = chnk_rs_hmap_instantiate(&g_chnk_hmap[tbsp], &g_chnk_hmap_config); 
    cBYE(status);

    rmtree(g_data_dir_root[tbsp]);
    rmtree(g_meta_dir_root[tbsp]);
    status = mkdir(g_data_dir_root[tbsp], 0744); cBYE(status);
    status = mkdir(g_meta_dir_root[tbsp], 0744); cBYE(status);
    printf("<<<<<<<<<<<< STARTED  NEW SESSION ============\n");
  }


  // STOP  For hashmaps  for vector, ...
BYE:
  return status;
}
