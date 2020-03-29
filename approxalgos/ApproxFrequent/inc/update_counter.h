extern int 
update_counter (
    cntrs_t *cntrs,
    uint32_t sz_cntrs,
    cntrs_t *cnt_buffer, // [sz_cntrs] 
    uint32_t n_cnt_buffer,
    cntrs_t *merged_cntrs, // [2*sz_cntrs] 
    uint32_t *ptr_n_cntrs
    );
