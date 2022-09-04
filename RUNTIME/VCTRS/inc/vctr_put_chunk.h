extern int
vctr_put_chunk(
    uint32_t vctr_uqid,
    char **ptr_X, // [vctr.chnk_size]
    bool is_stealable,
    uint32_t n // number of elements 1 <= n <= vctr.chnk_size
    );
