typedef struct _cntr_t { 
  int cntr_id;
  uint32_t cntr_freq;
} cntr_t;

typedef struct _approx_frequent_t { 
  cntr_id_freq_t *cntrs;
  uint32_t n_cntrs;
}
