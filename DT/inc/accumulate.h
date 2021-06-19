extern int
accumulate(
      const uint64_t * restrict Y, // [n_in]
      uint32_t lb,
      uint32_t ub,
      uint32_t prev_nT,
      uint32_t prev_nH,
      const metrics_t *M,
      uint32_t *ptr_nbuf, // how many in buffer when returning
      uint32_t *ptr_lb // how many consumed when returning.
      );
