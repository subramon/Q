extern int 
mk_loc(
    uint32_t *hashes, // input  [nkeys] 
    uint32_t nkeys, // input 
    uint32_t hmap_size, // input 
    uint64_t hmap_divinfo, // input 
    uint32_t *locs // output [nkeys] 
    );
