extern int
vctr_early_free(
    uint32_t tbsp,
    uint32_t uqid
    );
extern int
vctr_early_freeable(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    bool bval
    );
extern int 
vctr_is_early_freeable(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    bool *ptr_bval 
    );
