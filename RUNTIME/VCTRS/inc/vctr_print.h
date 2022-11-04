#include "vctr_rs_hmap_struct.h"
extern int
vctr_print(
    uint32_t uqid,
    uint32_t nn_uqid,
    const char * const opfile,
    const char * const format,
    uint64_t lb,
    uint64_t ub
    );
extern int
vctr_print_lma(
    FILE *fp,
    const char * const format,
    uint32_t vctr_uqid,
    vctr_rs_hmap_val_t *ptr_val,
    uint64_t lb,
    uint64_t ub
    );
