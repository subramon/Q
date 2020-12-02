extern int
hmap_get(
    hmap_t *ptr_hmap, 
    const void * const key, 
    size_t len,
    void **ptr_val,
    bool *ptr_is_found,
    uint32_t *ptr_where_found,
    dbg_t *ptr_dbg
    );
