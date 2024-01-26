#ifndef __LOAD_CSV_SEQ_H
#define __LOAD_CSV_SEQ_H
//START_FOR_CDEF
extern int
load_csv_seq(
    const char * infile,
    uint32_t nC,
    const char *str_fld_sep,
    uint32_t chunk_size,
    uint32_t max_width,
    uint64_t *ptr_nR,
    uint64_t *ptr_file_offset,
    const int *const c_qtypes, /* [nC] */
    int in_c_nn_qtype,
    const bool * const is_trim, /* [nC] */
    bool is_hdr, /* [nC] */
    const bool *  const is_load, /* [nC] */
    const bool * const has_nulls, /* [nC] */
    const uint32_t * const width, /* [nC] */
    char **data, /* [nC][chunk_size] */
    char **nn_data /* [nC][chunk_size] */
    );
//STOP_FOR_CDEF
#endif
