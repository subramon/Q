extern int
vctr_set_name(
    uint32_t tbsp,
    uint32_t uqid,
    const char * const name
    );
extern char *
vctr_get_name(
    uint32_t tbsp,
    uint32_t uqid
    );
extern char *
vctr_file_info(
    uint32_t tbsp,
    uint32_t uqid,
    int64_t *ptr_file_size
    );
extern int
vctr_set_error(
    uint32_t tbsp,
    uint32_t uqid
    );
extern int
vctr_is_error(
    uint32_t tbsp,
    uint32_t uqid,
    bool *ptr_is_err
    );
