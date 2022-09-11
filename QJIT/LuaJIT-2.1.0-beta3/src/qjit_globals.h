#ifdef MAIN_PGM
#define my_extern 
#else
#define my_extern extern
#endif
// Place globals in this file 
my_extern int g_halt;
my_extern int g_webserver_interested; 
// 1 => webserver is interested in acquiring Lua state 
my_extern int g_L_status; // values as described below 
// 0 => Lua state is free 
// 1 => Master owns Lua State 
// 2 => WebServer owns Lua State 
// hash map for vectors, chunks, vectors x chunks
my_extern vctr_rs_hmap_t g_vctr_hmap;
my_extern uint32_t g_vctr_uqid;

my_extern chnk_rs_hmap_t g_chnk_hmap;
my_extern uint32_t g_chnk_uqid;
// For master and memory manager
my_extern bool g_mutex_created;
my_extern pthread_cond_t  g_mem_cond;
my_extern pthread_mutex_t g_mem_mutex;
// Memory stuff
my_extern uint64_t g_mem_allowed; // maximum memory that C can allocate
my_extern uint64_t g_mem_used;    // amount of memory malloc'd

my_extern uint64_t g_dsk_allowed; // maximum disk that C can use
my_extern uint64_t g_dsk_used;    // amount of disk used
// Disk stuff
#define Q_MAX_LEN_DIR_NAME 255
my_extern char g_data_dir_root[Q_MAX_LEN_DIR_NAME+1];
my_extern char g_meta_dir_root[Q_MAX_LEN_DIR_NAME+1];
// save/restore
bool g_save_session;
