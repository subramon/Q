#include "struct_timers.h"
void reset_timers( VEC_TIMERS_TYPE *ptr_T) { 
ptr_T->t_check  = 0 ; ptr_T->n_check  = 0 ; 
ptr_T->t_clone  = 0 ; ptr_T->n_clone  = 0 ; 
ptr_T->t_delete_chunk_file  = 0 ; ptr_T->n_delete_chunk_file  = 0 ; 
ptr_T->t_delete_master_file  = 0 ; ptr_T->n_delete_master_file  = 0 ; 
ptr_T->t_flush  = 0 ; ptr_T->n_flush  = 0 ; 
ptr_T->t_free  = 0 ; ptr_T->n_free  = 0 ; 
ptr_T->t_get1  = 0 ; ptr_T->n_get1  = 0 ; 
ptr_T->t_start_read  = 0 ; ptr_T->n_start_read  = 0 ; 
ptr_T->t_get_chunk  = 0 ; ptr_T->n_get_chunk  = 0 ; 
ptr_T->t_new  = 0 ; ptr_T->n_new  = 0 ; 
ptr_T->t_put1  = 0 ; ptr_T->n_put1  = 0 ; 
ptr_T->t_put_chunk  = 0 ; ptr_T->n_put_chunk  = 0 ; 
ptr_T->t_rehydrate= 0 ; ptr_T->n_rehydrate= 0 ; 
ptr_T->t_shutdown  = 0 ; ptr_T->n_shutdown  = 0 ; 
ptr_T->t_start_write  = 0 ; ptr_T->n_start_write  = 0 ; 
ptr_T->t_malloc  = 0 ; ptr_T->n_malloc  = 0 ; 
ptr_T->t_memcpy  = 0 ; ptr_T->n_memcpy  = 0 ; 
ptr_T->t_memset  = 0 ; ptr_T->n_memset  = 0 ; 
}
