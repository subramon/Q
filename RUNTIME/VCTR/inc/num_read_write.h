extern int
vctr_get_num_rw(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t *ptr_num,
    const char * rw
    );
extern int
vctr_get_num_readers(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t *ptr_num
    );
extern int
vctr_get_num_writers(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t *ptr_num
    );
extern int
chnk_get_num_readers(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    uint32_t *ptr_num
    );
extern int
chnk_get_num_writers(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    uint32_t *ptr_num
    );
extern int
chnk_get_num_rw(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    uint32_t *ptr_num,
    const char * rw
    );
extern int
chnk_incr_num_readers(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx
    );
