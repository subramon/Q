#include "cmem_struct.h"
extern int
vctr_get_chunk(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t *ptr_num_in_chunk, // number in chunk
    bool *ptr_yes_vec_no_chunk
    );
extern int
vctr_unget_chunk(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    int chnk_idx
    );
