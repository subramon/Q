extern int
cprint(
    const char * const opfile,
    const uint64_t * const cfld,
    const void **const data, // [nC][nR] 
    int nC,
    uint64_t lb,
    uint64_t ub,
    const int * const enum_fldtypes,  
    const int *const widths // [nC]
    );
