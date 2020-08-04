//START_FOR_CDEF
extern int
cprint(
    char * opfile,
    uint64_t * cfld,
    void **data, // [nC][nR] 
    int nC,
    uint64_t lb,
    uint64_t ub,
    int * enum_fldtypes,  
    int * widths // [nC]
    );
//STOP_FOR_CDEF
