#ifndef __CORE_VEC_H
#define __CORE_VEC_H
#include "cmem_struct.h"
#include "qmem_struct.h"
#include "vctr_struct.h"

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
vec_meta(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    char **ptr_opbuf
    );
extern int
update_file_name(
    VEC_REC_TYPE *ptr_vec
    );
extern int
get_qtype_and_field_width(
    const char * const fldtype,
    char * res_qtype,
    int * res_field_width
    );
extern int 
vec_rehydrate(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    const char * const fldtype,
    uint32_t field_width,
    int64_t num_elements,
    int64_t vec_uqid,
    int64_t *chunk_uqids, // [num_chunks]
    uint32_t num_chunks
    );
extern int 
vec_new(
    VEC_REC_TYPE *ptr_vec,
    const char * const fldtype,
    uint32_t field_width
    );
extern int
vec_new_virtual(
    VEC_REC_TYPE *ptr_vec,
    char * map_addr,
    const char * const fldtype,
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
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_free(
    const qmem_struct_t *ptr_S,
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
vec_get1(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint64_t idx, 
    void **ptr_data
    );
extern int
vec_get_chunk(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint32_t chunk_num,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t *ptr_num_in_chunk
    );
extern int
vec_unget_chunk(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint32_t chunk_num
    );
extern int
is_eq_I4(
    void *X,
    int val
    );
extern int
vec_memo(
    const VEC_REC_TYPE *const ptr_vec,
    bool *ptr_is_memo,
    bool is_memo
    );
extern int
vec_start_read(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    CMEM_REC_TYPE *ptr_cmem
    );
extern int
vec_start_write(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    CMEM_REC_TYPE *ptr_cmem
    );
extern int
vec_end_read(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_end_write(
    const qmem_struct_t *ptr_S,
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
vec_delete(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec
    );
//--------------------------------------
extern int
vec_put_chunk(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t num_elements
    );
extern int
vec_put1(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    const void * const data
    );
extern int
vec_file_name(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    int32_t chunk_num,
    char **ptr_file_name
    );
//--------------------------
extern int
vec_delete_chunk_file(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    int chunk_num
    );
//-------------------------
extern int
check_chunks(
    const qmem_struct_t *ptr_S
    );
extern int
vec_shutdown(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    char **ptr_x
    );
extern int
vec_same_state(
    VEC_REC_TYPE *ptr_v1,
    VEC_REC_TYPE *ptr_v2
    );
extern int
vec_killable(
    VEC_REC_TYPE *ptr_vec,
    bool is_killable
    );
extern int
vec_kill(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_make_chunk_files(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    bool is_free_mem
    );
#endif
