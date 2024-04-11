extern int 
shard_file(
    const char * const infile,
    const char * const opdir,
    uint32_t nB, // number of subdirs in opdir
    uint32_t split_col_idx // which column to split on
    );
