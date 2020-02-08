extern int
cprint(
    const char * const opfile,
    uint64_t *cfld,
    void **data, // [nC][nR] 
    int nC,
    uint64_t lb,
    uint64_t ub,
    const char ** const fldtypes, // [nC]
    int *widths // [nC]
    );
