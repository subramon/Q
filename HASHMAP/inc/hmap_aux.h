extern uint32_t
mk_hmap_key(
    void
    );
extern uint32_t
set_hash(
    const void *const key,
    uint16_t len,
    hmap_t *ptr_hmap,
    dbg_t *ptr_dbg
    );
extern uint32_t
set_probe_loc(
    uint32_t hash,
    hmap_t *ptr_hmap,
    dbg_t *ptr_dbg
    );
extern int
hmap_pr(
    hmap_t *ptr_hmap
    );
extern void multi_free(
    hmap_multi_t *ptr_M
    );
extern  int multi_init(
    hmap_multi_t *ptr_M,
    int num_at_once
    );
extern uint32_t 
prime_geq(
    uint32_t n
    );
