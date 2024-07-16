extern int
vctr_add1(
    qtype_t qtype,
    uint32_t width,
    uint32_t in_chnk_size,
    bool is_memo,
    int memo_len,
    bool is_killable,
    int num_kill_ignore,
    bool is_early_freeable,
    int num_free_ignore,
    uint32_t *ptr_uqid
    );
