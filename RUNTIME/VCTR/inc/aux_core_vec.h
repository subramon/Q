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
      CHUNK_REC_TYPE *ptr_chunk, 
      uint32_t chunk_num,
      VEC_REC_TYPE *ptr_vec
      );
extern int
chk_chunk(
      uint32_t chunk_dir_idx
      );
extern int
allocate_chunk(
    size_t sz,
    uint32_t *ptr_idx
    );
extern int64_t 
get_exp_file_size(
    uint64_t num_elements,
    uint32_t field_width,
    const char * const fldtype
    );
extern int32_t
get_chunk_size(
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
    char *buf
    );
extern int
mk_file_name(
    uint64_t uqid, 
    char *file_name
    );
