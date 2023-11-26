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
    int *ptr_memo_len
    );
extern int
vctr_cast(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    const char * const str_qtype
    );
