//START_FOR_CDEF
int
vsplit(
    const char * infile,
    uint32_t nC,
    const char *str_fld_sep,
    uint32_t max_width,
    const int *const c_qtypes, /* [nC] */
    const bool *  const is_load, /* [nC] */
    const bool * const has_nulls, /* [nC] */
    const uint32_t * const width, /* [nC] */
    const char ** const opfiles,
    const char ** const nn_opfiles
    );
//STOP_FOR_CDEF
