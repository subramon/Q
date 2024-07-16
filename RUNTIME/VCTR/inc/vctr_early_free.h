extern int
vctr_early_free(
    uint32_t tbsp,
    uint32_t vctr_uqid
    );
extern int
vctr_set_num_free_ignore(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    int num_free_ignore
    );
extern int 
vctr_get_num_free_ignore(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    bool *ptr_is_early_freeable,
    int *ptr_num_free_ignore
    );
