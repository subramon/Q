
#include "q_incs.h"
extern int set_up_qtypes(
    char **fldtypes, // [nC] input 
    uint32_t nC,
    bool *is_load, // [nC] 
    bool **ptr_is_trim, // [nC] 
    qtype_type **ptr_qtypes // [nC] output
    );
