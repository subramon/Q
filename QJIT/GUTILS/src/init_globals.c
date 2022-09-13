#include "q_incs.h"
#include "q_macros.h"

#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_instantiate.h"

#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_instantiate.h"

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
#undef USE_WEB_SERVER
  g_mutex_created = false;
  g_halt = 0;
  g_webserver_interested = 0; 
  g_L_status = 0;

  g_save_session = true;
  memset(g_data_dir_root, 0, Q_MAX_LEN_DIR_NAME+1);
  memset(g_meta_dir_root, 0, Q_MAX_LEN_DIR_NAME+1);

  strcpy(g_data_dir_root, "/home/subramon/local/Q/data/"); 
  strcpy(g_meta_dir_root, "/home/subramon/local/Q/meta/"); 
  g_mem_allowed = 4 * 1024 * (uint64_t)1048576 ; // in Bytes
  g_mem_used    = 0;

  g_dsk_allowed = 32 * 1024 * (uint64_t)1048576 ; // in Bytes
  g_dsk_used    = 0;

  memset(&g_vctr_hmap, 0, sizeof(vctr_rs_hmap_t));
  g_vctr_uqid = 0; 

  memset(&g_chnk_hmap, 0, sizeof(chnk_rs_hmap_t));
  g_chnk_uqid = 0; 
  //-----------------------
  // For webserver
#ifdef WEB_SERVER
  pthread_t l_webserver;
  web_info_t web_info; 

  memset(&web_info, 0, sizeof(web_info_t));
  web_info.port = 8004; // TODO P2 Un-hard code 
  web_info.is_out_of_band = false;
  status = pthread_create(&l_webserver, NULL, &webserver, &web_info);
  cBYE(status);
  // For out of band 
  pthread_t l_out_of_band;
  web_info_t out_of_band_info; 
  memset(&out_of_band_info, 0, sizeof(web_info_t));
  out_of_band_info.port = 8008; // TODO P2 Un-hard code 
  out_of_band_info.is_out_of_band = true;
  status = pthread_create(&l_out_of_band, NULL, &webserver, 
      &out_of_band_info);
  cBYE(status);
  // For memory manager
  pthread_cond_init(&g_mem_cond, NULL);
  pthread_mutex_init(&g_mem_mutex, NULL);
  g_mutex_created = true;

  pthread_t l_mem_mgr;
  mem_mgr_info_t mem_mgr_info; memset(&mem_mgr_info, 0, sizeof(mem_mgr_info_t));
  mem_mgr_info.dummy = 123456789;
  status = pthread_create(&l_mem_mgr, NULL, &mem_mgr, &mem_mgr_info);
  cBYE(status);
  pthread_cond_signal(&g_mem_cond);
#endif

  // START For hashmaps  for vector, ...
  rs_hmap_config_t HC1; memset(&HC1, 0, sizeof(rs_hmap_config_t));
  HC1.min_size = 32;
  HC1.max_size = 0;
  HC1.so_file = strdup("libhmap_vctr.so"); 
  status = vctr_rs_hmap_instantiate(&g_vctr_hmap, &HC1); cBYE(status);

  rs_hmap_config_t HC2; memset(&HC2, 0, sizeof(rs_hmap_config_t));
  HC2.min_size = 32;
  HC2.max_size = 0;
  HC2.so_file = strdup("libhmap_chnk.so"); 
  status = chnk_rs_hmap_instantiate(&g_chnk_hmap, &HC2); cBYE(status);


  // STOP  For hashmaps  for vector, ...
BYE:
  return status;
}
