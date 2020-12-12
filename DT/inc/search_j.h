extern int 
search_j(
    uint64_t *Yj, /* [m][n] */
    uint32_t j,
    uint32_t lb, // 0 <= lb < n */
    uint32_t ub, // lb < ub < n */
    uint32_t m,
    uint32_t n,
    uint32_t nT,
    uint32_t nH,
    four_nums_t *ptr_num4,
    uint32_t *ptr_yval,
    uint32_t *ptr_yidx,
    double *ptr_metric
   );
