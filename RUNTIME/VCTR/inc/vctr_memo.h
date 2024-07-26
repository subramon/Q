extern int
vctr_set_memo(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    int memo_len
    );
extern int
vctr_get_memo_len(
    uint32_t tbsp,
    uint32_t uqid,
    bool *ptr_is_memo,
    int *ptr_memo_len
    );
extern int
vctr_memo(
    uint32_t vctr_loc,
    uint32_t vctr_uqid
    );
