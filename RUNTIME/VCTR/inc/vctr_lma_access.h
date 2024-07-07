#include "cmem_struct.h"
#include "vctr_rs_hmap_struct.h"
extern int 
vctr_unget_lma_X_nX(
    vctr_rs_hmap_val_t *ptr_val,
    char **ptr_X,
    size_t *ptr_nX
    );
extern int
vctr_get_lma_X_nX(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    vctr_rs_hmap_val_t *ptr_val,
    char **ptr_X,
    size_t *ptr_nX
    );
extern int
vctr_get_lma_read(
    uint32_t tbsp,
    uint32_t uqid,
    CMEM_REC_TYPE *ptr_cmem
    );
extern int
vctr_get_lma_write(
    uint32_t tbsp,
    uint32_t uqid,
    CMEM_REC_TYPE *ptr_cmem
    );
extern int
vctr_unget_lma_read(
    uint32_t tbsp,
    uint32_t uqid
    );
extern int
vctr_unget_lma_write(
    uint32_t tbsp,
    uint32_t uqid
    );
