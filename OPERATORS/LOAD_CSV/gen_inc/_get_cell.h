
#include <stdio.h>
#include <string.h>
#include "q_incs.h"
#include "_trim.h"
extern size_t
get_cell(
    char *X,
    size_t nX,
    size_t xidx,
    bool is_last_col,
    char *buf,
    char *lbuf,
    size_t bufsz
    );
