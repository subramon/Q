// Set globals in C in main program after creating Lua state
// but before doing anything else
// chunk_size, memory structures, ...
//
#include "core_vec_struct.h"
#ifdef MAIN_PGM
#define my_extern 
#else
#define my_extern extern 
#endif

my_extern 
my_extern uint32_t g_chunk_size;
my_extern CHUNK_REC_TYPE *g_chunk_dir;  // [g_sz_chunk_dir]
my_extern uint32_t g_sz_chunk_dir; 
my_extern uint32_t g_n_chunk_dir;  // 0 <= g_n_chunk_dir <= g_sz_chunk_dir
my_extern char g_q_data_dir[Q_MAX_LEN_DIR];

#include "_define_timers.h"
