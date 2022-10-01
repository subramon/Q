//START_FOR_CDEF
extern int
cprint(
    const char * const opfile,
    const uint64_t * const cfld, // TODO 
    void ** restrict data, // [nC][nR] 
    int nC,
    uint64_t lb,
    uint64_t ub,
    const int  * const qtypes,  
    const int * const width // [nC]
    );
//STOP_FOR_CDEF
