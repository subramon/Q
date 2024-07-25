extern int
vctr_set_nn_vec(
    uint32_t base_tbsp,
    uint32_t base_uqid,
    uint32_t nn_tbsp,
    uint32_t nn_uqid
    );
extern int 
vctr_get_nn_vec(
    uint32_t tbsp,
    uint32_t base_uqid,
    bool *ptr_has_nn,
    uint32_t *ptr_nn_uqid
    );
extern int
vctr_brk_nn_vec(
    uint32_t base_tbsp,
    uint32_t base_uqid
    );
