extern int
new_hmap_put(
    hmap_t *ptr_hmap, 
    void *key, 
    void *val,
    void *fn, // function pointer 
    dbg_t *ptr_dbg
    );
