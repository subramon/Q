extern int 
split(
    uint32_t **to, /* [m][n] */
    uint8_t *g, // for debugging 
    uint32_t lb,
    uint32_t ub,
    uint32_t nT,
    uint32_t nH,
    uint32_t n,
    uint32_t m,
    uint64_t **Y, /* [m][n] */
    uint64_t *tmpY /* [n] */
   );
