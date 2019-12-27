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
chk_field_type(
    const char * const field_type,
    uint32_t field_width
    );
extern int
free_chunk(
    uint32_t chunk_dir_idx,
    bool is_persist
    );
extern int
load_chunk(
    const CHUNK_REC_TYPE *const ptr_chunk, 
    const VEC_REC_TYPE *const ptr_vec,
    uint64_t *ptr_t_last_get,
    char **ptr_data
    );
extern int
chk_chunk(
      uint32_t chunk_dir_idx,
      uint64_t vec_uqid
      );
extern int
allocate_chunk(
    size_t sz,
    uint32_t chunk_idx,
    uint64_t vec_uqid,
    uint32_t *ptr_chunk_dir_idx,
    bool is_malloc
    );
extern int64_t 
get_exp_file_size(
    uint64_t num_elements,
    uint32_t field_width,
    const char * const fldtype
    );
extern int32_t
get_chunk_size_in_bytes(
    uint32_t field_width, 
    const char * const field_type
    );
extern void 
l_memcpy(
    void *dest,
    const void *src,
    size_t n
    );
extern void 
l_memset(
    void *s, 
    int c, 
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
mk_file_name(
    uint64_t uqid, 
    char *file_name,
    int len_file_name
    );
extern int
initial_case(
    VEC_REC_TYPE *ptr_vec
    );
extern int 
chunk_dir_idx_for_read(
    VEC_REC_TYPE *ptr_vec,
    uint64_t idx,
    uint32_t *ptr_chunk_dir_idx
    );
extern int
get_chunk_num_for_write(
    VEC_REC_TYPE *ptr_vec,
    uint32_t *ptr_chunk_num
    );
extern int
init_chunk_dir(
    VEC_REC_TYPE *ptr_vec,
    int num_chunks
    );
extern int 
get_chunk_dir_idx(
    const VEC_REC_TYPE *const ptr_vec,
    uint32_t chunk_idx,
    uint32_t *chunks,
    uint32_t *ptr_num_chunks,
    uint32_t *ptr_chunk_dir_idx
    );
extern int
vec_new_common(
    VEC_REC_TYPE *ptr_vec,
    const char * const field_type,
    uint32_t field_width
    );
extern int
delete_vec_file(
    const VEC_REC_TYPE *ptr_vec,
    bool *ptr_is_file, 
    uint64_t *ptr_file_size
    );
extern int
delete_chunk_file(
    const CHUNK_REC_TYPE *ptr_chunk,
    bool is_persist,
    bool *ptr_is_file
    );
extern int
reincarnate(
    VEC_REC_TYPE *ptr_v,
    char **ptr_x
    );
extern int
init_globals(
    void
    );
