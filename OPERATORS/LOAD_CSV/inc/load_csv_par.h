extern int
load_csv_par(
    const char * data_file,
    bool is_hdr,
    uint64_t *ptr_bytes_read,  // INPUT and OUTPUT 
    uint32_t nC, // number of columns
    const char *str_fld_sep,
    uint32_t chunk_size,
    uint32_t chunk_num,
    uint32_t max_width,
    uint32_t *ptr_num_rows_this_chunk, // OUTPUT 
    // when function returns, above contains number rows read in this chunk
    const int *const c_qtypes, /* [nC] */
    const bool * const is_trim, /* [nC] */
    const bool *  const is_load, /* [nC] */
    const bool * const has_nulls, /* [nC] */
    const uint32_t * const width, /* [nC] */
    uint32_t c_nn_qtype, // ideally uint32_t should be qtype_t 
    char ** restrict data, /* [nC][chunk_size] */
    bool ** restrict nn_data, /* [nC][chunk_size] */
    const char * lengths_file // NEW FOR PAR 
    );
