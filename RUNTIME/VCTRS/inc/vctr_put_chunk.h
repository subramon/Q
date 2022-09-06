#include <stdint.h>
#include "cmem_struct.h"
extern int
vctr_put_chunk(
    uint32_t vctr_uqid,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t n // number of elements 1 <= n <= vctr.chnk_size
    );
