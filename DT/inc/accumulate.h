extern int
accumulate(
      const uint64_t * restrict Y, // [n_in]
      uint32_t lb,
      uint32_t ub,
      uint32_t *yval, // [bufsz] 
      uint32_t cnts[2][BUFSZ], // [2][bufsz] 
      uint32_t bufsz,
      uint32_t *ptr_nbuf, // how many in buffer when returning
      uint32_t *ptr_lb // how many consumed when returning.
      );
