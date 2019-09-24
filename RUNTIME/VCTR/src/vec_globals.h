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
extern uint32_t g_chunk_size;
extern CHUNK_REC_TYPE *g_chunk_dir;  // [g_sz_chunk_dir]
extern uint32_t g_sz_chunk_dir; 
extern uint32_t g_n_chunk_dir;  // 0 <= g_n_chunk_dir <= g_sz_chunk_dir
extern char g_q_data_dir[Q_MAX_LEN_DIR];

extern uint64_t t_l_vec_check;       extern uint32_t n_l_vec_check;
extern uint64_t t_l_vec_clone;       extern uint32_t n_l_vec_clone;
extern uint64_t t_l_vec_flush;       extern uint32_t n_l_vec_flush;
extern uint64_t t_l_vec_free;        extern uint32_t n_l_vec_free;
extern uint64_t t_l_vec_get1;        extern uint32_t n_l_vec_get1;
extern uint64_t t_l_vec_get_all;     extern uint32_t n_l_vec_get_all;
extern uint64_t t_l_vec_get_chunk;   extern uint32_t n_l_vec_get_chunk;
extern uint64_t t_l_vec_new;         extern uint32_t n_l_vec_new;
extern uint64_t t_l_vec_put1;        extern uint32_t n_l_vec_put1;
extern uint64_t t_l_vec_start_write; extern uint32_t n_l_vec_start_write;
//
//-- memory associated functions
extern uint64_t t_malloc;            extern uint32_t n_malloc;
extern uint64_t t_memcpy;            extern uint32_t n_memcpy;
extern uint64_t t_memset;            extern uint32_t n_memset;
