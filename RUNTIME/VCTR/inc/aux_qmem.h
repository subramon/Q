#include "qmem_struct.h"
extern uint64_t
get_uqid(
    qmem_struct_t *ptr_S
    );
int
delete_vec_file(
    uint64_t uqid,
    uint32_t whole_vec_dir_idx,
    bool is_persist,
    const qmem_struct_t *ptr_S
    );
