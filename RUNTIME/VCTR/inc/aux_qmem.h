#include "qmem_struct.h"
extern size_t
get_chunk_size_in_bytes(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_v
    );
extern uint64_t
get_uqid(
    qmem_struct_t *ptr_S
    );
extern int
chk_chunk(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const v,
    uint32_t chunk_dir_idx
    );
extern int
allocate_chunk(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v,
    uint32_t chunk_num,
    uint32_t *ptr_chunk_dir_idx,
    bool is_malloc
    );
extern int 
get_chunk_dir_idx(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint32_t chunk_num,
    uint32_t *ptr_num_chunks,
    uint32_t *ptr_chunk_dir_idx,
    bool is_malloc
    );
extern int
mk_file_name(
    qmem_struct_t *ptr_S,
    uint64_t uqid, 
    char **ptr_file_name
    );
//--------------------------------------
extern int
qmem_load_chunk(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const ptr_vec,
    int chunk_num
    );
extern int
qmem_un_load_chunk(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const ptr_vec,
    int chunk_num,
    bool is_hard
    );
//--------------------------------------
extern int
qmem_backup_chunk(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const ptr_vec,
    int chunk_num
    );
extern int
qmem_un_backup_chunk(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const ptr_vec,
    uint32_t chunk_num,
    bool is_hard
    );
//--------------------------------------
extern int
qmem_un_backup_vec(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v,
    bool is_hard
    );
extern int 
qmem_backup_vec(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_v
    );
//--------------------------------------
extern int
qmem_backup_chunks(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const ptr_vec
    );
extern int
qmem_un_backup_chunks(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v,
    bool is_hard
    );
//--------------------------------------
extern int
qmem_load_chunks(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const ptr_vec
    );
extern int
qmem_un_load_chunks(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const v,
    bool is_hard
    );
extern bool 
vec_in_use(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v
    );
extern int
qmem_delete_vec(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec
    );
extern int
register_with_qmem(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v
    );
extern int
assign_vec_idx(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v
    );
