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
my_extern uint32_t g_chunk_size;
my_extern CHUNK_REC_TYPE *g_chunk_dir;  // [g_sz_chunk_dir]
my_extern uint32_t g_sz_chunk_dir; 
my_extern uint32_t g_n_chunk_dir;  // 0 <= g_n_chunk_dir <= g_sz_chunk_dir
my_extern char g_q_data_dir[Q_MAX_LEN_DIR];

my_extern uint64_t t_l_vec_check;       my_extern uint32_t n_l_vec_check;
my_extern uint64_t t_l_vec_clone;       my_extern uint32_t n_l_vec_clone;
my_extern uint64_t t_l_vec_flush;       my_extern uint32_t n_l_vec_flush;
my_extern uint64_t t_l_vec_free;        my_extern uint32_t n_l_vec_free;
my_extern uint64_t t_l_vec_get1;        my_extern uint32_t n_l_vec_get1;
my_extern uint64_t t_l_vec_get_all;     my_extern uint32_t n_l_vec_get_all;
my_extern uint64_t t_l_vec_get_chunk;   my_extern uint32_t n_l_vec_get_chunk;
my_extern uint64_t t_l_vec_new;         my_extern uint32_t n_l_vec_new;
my_extern uint64_t t_l_vec_put1;        my_extern uint32_t n_l_vec_put1;
my_extern uint64_t t_l_vec_put_chunk;   my_extern uint32_t n_l_vec_put_chunk;
my_extern uint64_t t_l_vec_start_write; my_extern uint32_t n_l_vec_start_write;
//
//-- memory associated functions
my_extern uint64_t t_malloc;            my_extern uint32_t n_malloc;
my_extern uint64_t t_memcpy;            my_extern uint32_t n_memcpy;
my_extern uint64_t t_memset;            my_extern uint32_t n_memset;
