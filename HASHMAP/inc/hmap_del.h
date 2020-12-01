extern int
hmap_del(
    hmap_t *ptr_hmap, 
    const void *key, 
    size_t len,
    val_t *ptr_val,
    bool *ptr_is_found,
    dbg_t *ptr_dbg
    );
