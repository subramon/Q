extern int forward(
    float **in,  /* [n_in][nI] */
    float ***W,   /* [nl][n_in][n_out] */ /* TODO: Order to be debated */
    float **b,    /* bias[nl][n_out] */
    float **out, /* [n_out][nI] */
    int32_t nI, 
    int32_t *npl, /* [nl] */
    int32_t nl
   );
