extern int 
chk_data(
    char **data, 
    bool **nn_data, 
    uint32_t nC, 
    bool *has_nulls, // [nC]
    bool *is_load, // [nC]
    uint32_t *width,  // [nC]
    uint32_t max_width
    );
