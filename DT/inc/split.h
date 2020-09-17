extern int 
split(
    float **X, /* [m][n] */
    uint32_t lb,
    uint32_t ub,
    uint32_t n,
    uint32_t m,
    uint8_t *g,
    uint32_t ***ptr_Y
   );
