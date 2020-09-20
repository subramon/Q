extern int 
pr_data_f(
    float **X, /* [m][n] */
    uint32_t m,
    uint32_t n,
    uint8_t *g,
    uint32_t lb,
    uint32_t ub
   );
extern int 
pr_data_i(
    float **X, /* [m][n] */
    uint32_t **Y, /* [m][n] */
    uint32_t **from, /* [m][n] */
    uint32_t **to, /* [m][n] */
    uint32_t m,
    uint32_t n,
    uint8_t *lr,
    uint8_t *g,
    uint32_t lb,
    uint32_t ub
   );
