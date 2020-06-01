#include "struct_timers.h"
void print_timers( VEC_TIMERS_TYPE *ptr_T) { 
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_check , ptr_T->t_check );
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_clone , ptr_T->t_clone );
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_delete_chunk_file , ptr_T->t_delete_chunk_file );
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_delete_master_file , ptr_T->t_delete_master_file );
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_flush , ptr_T->t_flush );
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_free , ptr_T->t_free );
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_get1 , ptr_T->t_get1 );
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_start_read , ptr_T->t_start_read );
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_get_chunk , ptr_T->t_get_chunk );
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_new , ptr_T->t_new );
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_put1 , ptr_T->t_put1 );
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_put_chunk , ptr_T->t_put_chunk );
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_rehydrate, ptr_T->t_rehydrate);
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_shutdown , ptr_T->t_shutdown );
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_start_write , ptr_T->t_start_write );
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_malloc , ptr_T->t_malloc );
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_memcpy , ptr_T->t_memcpy );
fprintf(stdout, "0,check,%u,%" PRIu64 "\n", ptr_T->n_memset , ptr_T->t_memset );
}
