#include <stdbool.h>
//START_FOR_CDEF
extern size_t
get_cell(
    char *X,
    size_t nX,
    size_t xidx,
    char fld_sep,
    bool is_last_col,
    char *buf,
    char *lbuf,
    size_t bufsz,
    bool *ptr_is_err
    );
//STOP_FOR_CDEF
