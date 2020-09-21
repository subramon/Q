extern int 
split(
    uint32_t **to, /* [m][n] */
    uint32_t lb,
    uint32_t ub,
    uint32_t n,
    uint32_t m,
    uint64_t **Y, /* [m][n] */
    uint64_t *tmpY /* [n] */
   );
