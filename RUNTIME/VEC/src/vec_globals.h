// Set globals in C in main program after creating Lua state
// but before doing anything else
// chunk_size, memory structures, ...
//
#include "core_vec_struct.h"
extern uint32_t g_chunk_size;
extern CHUNK_REC_TYPE *g_chunk_dir;  // [g_sz_chunk_dir]
extern uint32_t g_sz_chunk_dir; 
extern uint32_t g_n_chunk_dir;  // 0 <= g_n_chunk_dir <= g_sz_chunk_dir
extern char g_q_data_dir[Q_MAX_LEN_DIR];
