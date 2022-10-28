extern int
isby_I8_I4(
    const int64_t *const src_lnk,
    const int32_t *const src_val,
    uint32_t src_len,
    const int64_t *const dst_lnk,
    int32_t * restrict dst_val,
    bool * restrict nn_dst_val,
    uint32_t dst_len,
    uint32_t *ptr_src_idx,
    uint32_t *ptr_dst_idx
    );
