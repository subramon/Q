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
