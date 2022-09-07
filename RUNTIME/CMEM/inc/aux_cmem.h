extern int 
cmem_free( 
    CMEM_REC_TYPE *ptr_cmem
    );
extern int 
cmem_dupe( // INTERNAL NOT VISIBLE TO LUA 
    CMEM_REC_TYPE *ptr_cmem,
    void *data,
    int64_t size,
    qtype_t qtype,
    const char * const cell_name
    );
extern int 
cmem_malloc( // INTERNAL NOT VISIBLE TO LUA 
    CMEM_REC_TYPE *ptr_cmem,
    int64_t size,
    qtype_t qtype,
    const char *const cell_name
    );
