extern int
hmap_mput(
    hmap_t *ptr_hmap, 
    hmap_multi_t *M,

    void **keys,  // [nkeys] 
    uint16_t *key_lens, // [nkeys] 

    void *alt_keys, // either keys or alt_keys but not both
    uint32_t key_len, 

    uint32_t nkeys,

    void **vals, // [nkeys] 
    void *alt_vals, // either keys or alt_keys but not both
    uint32_t val_len
    );
