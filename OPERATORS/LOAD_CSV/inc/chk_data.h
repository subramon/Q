extern int 
chk_data(
    char ** data, 
    char ** nn_data, 
    uint32_t nC, 
    const bool * const has_nulls, // [nC]
    const bool * const is_load, // [nC]
    const uint32_t * const width,  // [nC]
    uint32_t max_width
    );
