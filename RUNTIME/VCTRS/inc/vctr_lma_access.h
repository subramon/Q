extern char *
vctr_steal_lma(
    uint32_t uqid
    );
extern int
vctr_get_lma_read(
    uint32_t uqid,
    CMEM_REC_TYPE *ptr_cmem
    );
extern int
vctr_get_lma_write(
    uint32_t uqid,
    CMEM_REC_TYPE *ptr_cmem
    );
extern int
vctr_unget_lma_read(
    uint32_t uqid
    );
extern int
vctr_unget_lma_write(
    uint32_t uqid
    );
