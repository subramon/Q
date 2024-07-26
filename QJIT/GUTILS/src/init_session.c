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
#include "init_session.h"

int
init_session(
    void
    )
{
  int status = 0;
  uint32_t *uqids_to_del = NULL;
  // For webserver 
  if ( g_is_webserver ) {  
    printf("Spawned webserver\n");
    g_web_info.is_out_of_band = false;
    status = pthread_create(&g_webserver, NULL, &webserver, &g_web_info);
    cBYE(status);
  }
  // For out of band 
  if ( g_is_out_of_band ) {  
    printf("Spawned out-of-band server\n");
    g_out_of_band_info.is_out_of_band = true;
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
    // We need to delete any vectors that had *NOT* been persisted
    // Cannot do this in the loop below. Must be done before
    // Reason is that when you delete, things move around
    // STEP 1: Count how many to be deleted 
    int num_to_delete = 0;
    for ( uint32_t i = 0; i < g_vctr_hmap[tbsp].size; i++ ) { 
      if ( !g_vctr_hmap[tbsp].bkt_full[i] ) { continue; } 
      if ( g_vctr_hmap[tbsp].bkts[i].val.is_persist == true ) { continue; }
      num_to_delete++;
    }
    // STEP 2: Assemble vctr_uqid's of those to be deleted
    if ( num_to_delete > 0 )  {
      printf("Ready to delete %u vectors\n", num_to_delete);
      uqids_to_del = malloc(num_to_delete * sizeof(uint32_t));
      return_if_malloc_failed(uqids_to_del); 
      num_to_delete = 0;
      for ( uint32_t i = 0; i < g_vctr_hmap[tbsp].size; i++ ) { 
        if ( !g_vctr_hmap[tbsp].bkt_full[i] ) { continue; } 
        if ( g_vctr_hmap[tbsp].bkts[i].val.is_persist == true ) { continue; }
        vctr_rs_hmap_key_t key = g_vctr_hmap[tbsp].bkts[i].key;
        uint32_t vctr_uqid = key;
        uqids_to_del[num_to_delete++] = vctr_uqid; 
      }
      // STEP 3: now go ahead and delete them 
      for ( int i = 0; i < num_to_delete; i++ ) { 
        uint32_t vctr_uqid = uqids_to_del[i];
        bool is_found = false;
        status = vctr_del(tbsp, vctr_uqid, &is_found); cBYE(status);
        if ( !is_found ) { go_BYE(-1); } 
        printf("Deleted vector %u \n", vctr_uqid);
      }
    }
    //-------------------
    for ( uint32_t i = 0; i < g_vctr_hmap[tbsp].size; i++ ) { 
      if ( !g_vctr_hmap[tbsp].bkt_full[i] ) { continue; } 
      g_vctr_hmap[tbsp].bkts[i].val.X = NULL;
      g_vctr_hmap[tbsp].bkts[i].val.nX = 0;
      g_vctr_hmap[tbsp].bkts[i].val.is_killable = false;
      g_vctr_hmap[tbsp].bkts[i].val.num_readers = 0;
      g_vctr_hmap[tbsp].bkts[i].val.num_writers = 0;
      vctr_rs_hmap_key_t key = g_vctr_hmap[tbsp].bkts[i].key;
      uint32_t vctr_uqid = key;
      if ( vctr_uqid > g_vctr_uqid ) { g_vctr_uqid = vctr_uqid; } 
      g_vctr_hmap[tbsp].bkts[i].val.ref_count   = 0;
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
    else {
      printf("Deleted %d vectors that were not persisted\n", num_to_delete);
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
    status = mkdir(g_meta_dir_root, 0744); cBYE(status);
    printf("<<<<<<<<<<<< STARTED  NEW SESSION ============\n");
  }


  // STOP  For hashmaps  for vector, ...
BYE:
  free_if_non_null(uqids_to_del);
  return status;
}
