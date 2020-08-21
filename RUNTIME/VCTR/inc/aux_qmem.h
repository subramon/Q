#include "qmem_struct.h"
extern uint64_t
get_uqid(
    qmem_struct_t *ptr_S
    );
extern int
chk_chunk(
    const qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const v,
    uint32_t chunk_dir_idx
    );
extern int
delete_vec(
    uint64_t uqid,
    bool is_persist,
    const qmem_struct_t *ptr_S,
    uint32_t whole_vec_dir_idx
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
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint32_t chunk_num,
    uint32_t *ptr_num_chunks,
    uint32_t *ptr_chunk_dir_idx,
    bool is_malloc
    );
