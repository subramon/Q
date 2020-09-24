extern int
accumulate(
      const uint64_t * restrict Y, // [n_in]
      uint32_t lb,
      uint32_t ub,
      uint32_t prev0,
      uint32_t prev1,
      uint32_t M_yval[BUFSZ],
      uint32_t M_yidx[BUFSZ],
      uint32_t M_nT[BUFSZ],
      uint32_t M_nH[BUFSZ],
      uint32_t *ptr_nbuf, // how many in buffer when returning
      uint32_t *ptr_lb // how many consumed when returning.
      );
