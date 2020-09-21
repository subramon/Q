extern int 
chk_set_equality(
    uint32_t *X,
    uint32_t *Y,
    uint32_t n,
    bool *ptr_is_eq
    );
extern int 
check(
    uint32_t **to, /* [m][n] */
    uint8_t *g, // for debugging 
    uint32_t lb,
    uint32_t ub,
    uint32_t n,
    uint32_t m,
    uint64_t **Y /* [m][n] */
   );
extern int 
chk_is_unique(
    uint32_t *X,
    uint32_t n,
    bool *ptr_is_distinct
    );
