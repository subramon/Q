#include "cmem_struct.h"
extern int
vctr_get_chunk(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t *ptr_n, // number in chunk
    uint32_t *ptr_num_readers // number in chunk
    );
extern int
vctr_unget_chunk(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx
    );
extern int
vctr_num_readers(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    uint32_t *ptr_num_readers // number in chunk
    );
