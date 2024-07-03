//START_FOR_CDEF
extern int
load_data_from_file(
    const char * const src_file,
    uint64_t file_offset,
    uint64_t num_to_copy,
    uint64_t num_copied,
    uint32_t width,
    char *dst
    );
//STOP_FOR_CDEF
