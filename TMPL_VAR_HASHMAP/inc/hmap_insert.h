extern int
hmap_insert(
    hmap_t *ptr_hmap, 
    void * key,
    void * val,
    bool is_resize,
    dbg_t *ptr_dbg
    );
