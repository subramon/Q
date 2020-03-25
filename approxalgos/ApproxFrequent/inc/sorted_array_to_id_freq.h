extern int
sorted_array_to_id_freq (
    double * in_buf, // [n_in_buf]          // input 
    uint32_t n_in_buf, // input 
    cntrs_t *out_buf, // [sz_out_buf]  // answers written here
    uint32_t sz_out_buf, 
    uint32_t *ptr_n_out_buf // output 
    );
