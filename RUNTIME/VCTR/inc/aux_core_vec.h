#include "qmem_struct.h"
extern bool 
is_file_size_okay(
    const char *const file_name,
    int64_t expected_size
    );
extern int 
chk_name(
    const char * const name
    );
extern int
chk_fldtype(
    const char * const fldtype,
    uint32_t field_width
    );
extern int
free_chunk(
    const qmem_struct_t *ptr_S,
    uint32_t chunk_dir_idx,
    bool is_persist
    );
extern int64_t 
get_exp_file_size(
    const qmem_struct_t *ptr_S,
    uint64_t num_elements,
    uint32_t field_width,
    const char * const fldtype
    );
extern void 
l_memcpy(
    void *dest,
    const void *src,
    size_t n
    );
extern void *
l_malloc(
    size_t n
    );
extern int
as_hex(
    uint64_t n,
    char *buf,
    size_t buflen
    );
extern int
initial_case(
    VEC_REC_TYPE *ptr_vec
    );
extern int 
chunk_num_for_read(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint64_t idx,
    uint32_t *ptr_chunk_num
    );
extern int
get_chunk_num_for_write(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint32_t *ptr_chunk_num
    );
extern int
init_chunk_dir(
    VEC_REC_TYPE *ptr_vec,
    int num_chunks
    );
extern int
reincarnate(
    const qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const ptr_v,
    char **ptr_x,
    bool is_clone 
    );
extern bool
is_multiple(
    uint64_t x, 
    uint32_t y
    );
extern int 
make_master_file(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_v,
    bool is_free_mem
    );
extern int
safe_strcat(
    char **ptr_X,
    size_t *ptr_nX,
    const char * const buf
    );
extern uint64_t
mk_uqid(
    qmem_struct_t *ptr_S
    );
extern int
vec_clean_chunks(
    const qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const ptr_vec
    );
