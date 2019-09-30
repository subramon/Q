#ifndef __CORE_VEC_H
#define __CORE_VEC_H
#include "cmem_struct.h"
#include "core_vec_struct.h"

extern void
vec_reset_timers(
    void
    );
extern void
vec_print_timers(
    void
    );
extern uint64_t
vec_print_mem(
   void 
    );
extern int
chk_field_type(
    const char * const field_type,
    uint32_t field_width
    );
extern int
vec_meta(
    VEC_REC_TYPE *ptr_vec,
    char *opbuf
    );
extern int
vec_nascent(
    VEC_REC_TYPE *ptr_vec
    );
extern int
update_file_name(
    VEC_REC_TYPE *ptr_vec
    );
extern int
get_qtype_and_field_width(
    const char * const field_type,
    char * res_qtype,
    int * res_field_width
    );
extern int 
vec_rehydrate(
    VEC_REC_TYPE *ptr_vec,
    const char * const field_type,
    uint32_t field_width,
    int64_t num_elements,
    const char *const file_name
    );
extern int 
vec_mrehydrate(
    VEC_REC_TYPE *ptr_vec,
    const char * const field_type,
    uint32_t field_width,
    int64_t num_elements,
    const char *const file_name
    );
extern int 
vec_new(
    VEC_REC_TYPE *ptr_vec,
    const char * const field_type,
    uint32_t field_width
    );
extern int
vec_new_virtual(
    VEC_REC_TYPE *ptr_vec,
    char * map_addr,
    const char * const field_type,
    uint32_t chunk_size,
    int64_t num_elements
    );
extern int
vec_materialized(
    VEC_REC_TYPE *ptr_vec,
    const char *const file_name
    );
extern int
vec_check(
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_free(
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_set(
    VEC_REC_TYPE *ptr_vec,
    char * const addr, 
    uint64_t idx, 
    uint32_t len
    );
extern int
vec_eov(
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_persist(
    VEC_REC_TYPE *ptr_vec,
    bool is_persist
    );
extern int
vec_get_all(
    VEC_REC_TYPE *ptr_vec,
    char **ptr_data,
    uint64_t *ptr_num_elements,
    CMEM_REC_TYPE *ptr_cmem
    );
extern int
vec_get1(
    VEC_REC_TYPE *ptr_vec,
    uint64_t idx, 
    char **ptr_data
    );
extern int
vec_get_chunk(
    VEC_REC_TYPE *ptr_vec,
    uint32_t chunk_num,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t *ptr_num_in_chunk
    );
extern int
is_eq_I4(
    void *X,
    int val
    );
extern int
vec_mono(
    VEC_REC_TYPE *ptr_vec,
    bool is_mono
    );
extern int
vec_memo(
    VEC_REC_TYPE *ptr_vec,
    bool is_memo
    );
extern int
vec_add(
    VEC_REC_TYPE *ptr_vec,
    char * const addr, 
    int32_t len
    );
extern int
vec_add_B1(
    VEC_REC_TYPE *ptr_vec,
    char * addr, 
    int32_t len
    );
extern int
vec_start_write(
    VEC_REC_TYPE *ptr_vec,
    CMEM_REC_TYPE *ptr_cmem
    );
extern int
vec_end_write(
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_set_name(
    VEC_REC_TYPE *ptr_vec,
    const char * const name
    );
extern char *
vec_get_name(
    VEC_REC_TYPE *ptr_vec
    );
extern int 
vec_cast(
    VEC_REC_TYPE *ptr_vec,
    const char * const new_qtype,
    uint32_t new_width
    );
extern int
vec_clean_chunk(
    VEC_REC_TYPE *ptr_vec
    );
extern char *
vec_get_buf(
  VEC_REC_TYPE *ptr_vec
);
extern int 
vec_clone(
    VEC_REC_TYPE *ptr_old_vec,
    VEC_REC_TYPE *ptr_new_vec
    );
extern int 
vec_no_memcpy(
    VEC_REC_TYPE *ptr_vec,
    CMEM_REC_TYPE *ptr_cmem,
    size_t chunk_size
    );
extern int
vec_delete(
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_flush_to_disk(
    VEC_REC_TYPE *ptr_vec,
    bool is_flush_all,
    int chunk_idx
    );
extern int
vec_put_chunk(
    VEC_REC_TYPE *ptr_vec,
    const char * const data,
    uint32_t num_elements,
    int64_t size
    );
extern int
vec_put1(
    VEC_REC_TYPE *ptr_vec,
    const char * const data
    );
extern int
vec_file_name(
    VEC_REC_TYPE *ptr_vec,
    int32_t chunk_num,
    char *file_name
    );
#endif
