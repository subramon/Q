//START_FOR_CDEF
extern int
cprint(
    const char * opfile,
    const void * const cfld, // TODO 
    const void ** data, // [nC][nR] 
    int nC,
    uint64_t lb,
    uint64_t ub,
    const int32_t  * const qtypes,  
    const int32_t * const widths // [nC]
    );
//STOP_FOR_CDEF
