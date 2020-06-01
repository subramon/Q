#ifndef _STRUCT_TIMERS 
#define _STRUCT_TIMERS 
 typedef struct _vec_timers_type { 
uint64_t t_check ; uint32_t n_check ;
uint64_t t_clone ; uint32_t n_clone ;
uint64_t t_delete_chunk_file ; uint32_t n_delete_chunk_file ;
uint64_t t_delete_master_file ; uint32_t n_delete_master_file ;
uint64_t t_flush ; uint32_t n_flush ;
uint64_t t_free ; uint32_t n_free ;
uint64_t t_get1 ; uint32_t n_get1 ;
uint64_t t_start_read ; uint32_t n_start_read ;
uint64_t t_get_chunk ; uint32_t n_get_chunk ;
uint64_t t_new ; uint32_t n_new ;
uint64_t t_put1 ; uint32_t n_put1 ;
uint64_t t_put_chunk ; uint32_t n_put_chunk ;
uint64_t t_rehydrate; uint32_t n_rehydrate;
uint64_t t_shutdown ; uint32_t n_shutdown ;
uint64_t t_start_write ; uint32_t n_start_write ;
uint64_t t_malloc ; uint32_t n_malloc ;
uint64_t t_memcpy ; uint32_t n_memcpy ;
uint64_t t_memset ; uint32_t n_memset ;
 } VEC_TIMERS_TYPE; 
#endif 
