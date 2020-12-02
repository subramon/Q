extern int
hmap_mput(
    hmap_t *ptr_hmap, 
    hmap_multi_t *M,
    void **keys,  // [nkeys] 
    uint32_t nkeys,
    uint16_t *lens, // [nkeys] 
    void **vals // [nkeys] 
    );
