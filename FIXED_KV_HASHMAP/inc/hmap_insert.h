extern int
hmap_insert(
    hmap_t *ptr_hmap, 
    void *key,
    uint16_t len,
    bool steal, // true => steal key; else make a copy
    void * val,
    dbg_t *ptr_dbg
    );
