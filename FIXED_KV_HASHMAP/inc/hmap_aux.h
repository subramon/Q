extern uint32_t
mk_hmap_key(
    void
    );
extern uint32_t
set_hash(
    const hmap_key_t * const ptr_key,
    const hmap_t * const ptr_hmap
    );
extern uint32_t
set_probe_loc(
    uint32_t hash,
    hmap_t *ptr_hmap
    );
extern int
hmap_pr(
    hmap_t *ptr_hmap
    );
extern uint32_t 
prime_geq(
    uint32_t n
    );
