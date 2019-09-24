extern int
chk_chunk(
      uint32_t chunk_dir_idx,
      bool is_free
      );
extern bool 
is_file_size_okay(
    const char *const file_name,
    size_t expected_size
    );
extern int 
chk_name(
    const char * const name
    );
extern int
chk_field_type(
    const char * const field_type,
    uint32_t field_size
    );
extern int
free_chunk(
    uint32_t chunk_dir_idx,
    bool is_persist
    );
extern int
get_qtype_and_field_size(
    const char * const field_type,
    char * res_qtype,
    int * res_field_size
    );
extern int
load_chunk(
      CHUNK_REC_TYPE *ptr_chunk, 
      VEC_REC_TYPE *ptr_vec
      );
extern int
chk_chunk(
      uint32_t chunk_dir_idx,
      bool is_free
      );
extern int32_t
allocate_chunk(
    void
    );
