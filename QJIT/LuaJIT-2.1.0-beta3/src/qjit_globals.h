#include <pthread.h>
#include "qjit_consts.h"
#include "web_struct.h"
#include "mem_mgr_struct.h"
#ifdef MAIN_PGM
#define my_extern 
#else
#define my_extern extern
#endif
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
// Place globals in this file 
my_extern int g_halt;
// g_halt is initialized to 0. It is set to 1 by halt_threads()
// which is in lgutils. Once set, subsequent calls to webserver thread
// or out_of_band thread will cause them to terminate
my_extern int g_webserver_interested; 
// 0 => webserver is NOT interested in acquiring Lua state 
// 1 => webserver is interested in acquiring Lua state 
// Set only in process_req() by webserver thread 
my_extern int g_L_status; // values as described below 
// 0 => Lua state is free 
// 1 => Master owns Lua State 
// 2 => WebServer owns Lua State 
// -------------------------------------------
// hash map for vectors, chunks, vectors x chunks
my_extern vctr_rs_hmap_t *g_vctr_hmap; // [Q_MAX_NUM_TABLESPACES];
// Note that we have only one g_vctr_uqid, not one per tablespace
// This is because the only use of g_vctr_uqid is when you add vectors
// and you cannot add vectors to any tablespace other than yor own (0)
my_extern uint32_t g_vctr_uqid; 
my_extern chnk_rs_hmap_t *g_chnk_hmap; // [Q_MAX_NUM_TABLESPACES];
// For master and memory manager
my_extern bool g_mutex_created;
my_extern pthread_cond_t  g_mem_cond;
my_extern pthread_mutex_t g_mem_mutex;
// for protecting concurrent access to usage counters, both
my_extern int g_mem_lock; 
// memrory stuff and disk stuff
// Memory stuff
my_extern uint64_t g_mem_allowed; // maximum memory that C can allocate
my_extern uint64_t g_mem_used;    // amount of memory malloc'd

my_extern uint64_t g_dsk_allowed; // maximum disk that C can use
my_extern uint64_t g_dsk_used;    // amount of disk used
// Disk stuff
my_extern char **g_data_dir_root; // [[Q_MAX_NUM_TABLESPACES][Q_MAX_LEN_DIR_NAME+1];
// IMPORTANT: Only one meta_dir_root is kept for default tablespace
my_extern char *g_meta_dir_root; // [Q_MAX_LEN_DIR_NAME+1];
// following is used to help debugging by giving logical names to tbsp
my_extern char **g_tbsp_name; // [Q_MAX_NUM_TABLESPACES][Q_MAX_LEN_DIR_NAME+1];
// restore
bool g_restore_session;
// for webserver
bool       g_is_webserver;
pthread_t  g_webserver;
web_info_t g_web_info;
// for out of band communication
bool       g_is_out_of_band;
pthread_t  g_out_of_band;
web_info_t g_out_of_band_info; 
// for memory manager
bool           g_is_mem_mgr;
pthread_t      g_mem_mgr;
mem_mgr_info_t g_mem_mgr_info; 
// configs for hash tables 
rs_hmap_config_t g_vctr_hmap_config; 
rs_hmap_config_t g_chnk_hmap_config; 
