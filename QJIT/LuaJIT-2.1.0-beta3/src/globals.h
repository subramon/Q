// Place globals in this file 
int g_halt;
int g_webserver_interested; 
// 1 => webserver is interested in acquiring Lua state 
int g_L_status; // values as described below 
// 0 => Lua state is free 
// 1 => Master owns Lua State 
// 2 => WebServer owns Lua State 
// hash map for vectors, chunks, vectors x chunks
rs_hmap_t g_vctr_hmap;
rs_hmap_t g_chnk_hmap;
uint32_t g_vctr_uqid;
uint32_t g_chnk_uqid;
// For master and memory manager
pthread_cond_t  g_mem_cond;
pthread_mutex_t g_mem_mutex;
