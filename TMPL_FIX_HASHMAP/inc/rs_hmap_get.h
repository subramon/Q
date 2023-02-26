extern int
rs_hmap_get(
    ${tmpl}_rs_hmap_t *ptr_hmap, 
    const void * const in_ptr_key, 
    void *in_ptr_val,
    bool *ptr_is_found,
    uint32_t *ptr_where_found
    );
