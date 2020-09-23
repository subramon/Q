extern int 
preproc(
    float ** restrict X, /* [m][n] */
    uint32_t m,
    uint32_t n,
    uint8_t * restrict g,
    uint32_t *ptr_nT, // encoded as 0
    uint32_t *ptr_nH, // encoded as 1
    uint64_t ***ptr_Y, 
    uint32_t ***ptr_to,
    uint64_t ***ptr_tmpY
    );
