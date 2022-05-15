#include "rs_hmap_int_struct.h"
extern uint32_t
mk_hmap_key(
    void
    );
extern uint32_t
set_hash(
    const rs_hmap_key_t * const ptr_key,
    const rs_hmap_t * const ptr_hmap
    );
extern uint32_t
set_probe_loc(
    uint32_t hash,
    rs_hmap_t *ptr_hmap
    );
extern int
hmap_pr(
    rs_hmap_t *ptr_hmap
    );
extern uint32_t 
prime_geq(
    uint32_t n
    );
