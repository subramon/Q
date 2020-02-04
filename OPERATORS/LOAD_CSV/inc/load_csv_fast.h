// I really don't like this hard coding below especially since
// bridge_C.lua needs to kept in sync with this. But it helped
// work around  some strange memory corruption
#define B1 1 
#define I1 2 
#define I2 3 
#define I4 4 
#define I8 5 
#define F4 6 
#define F8 7 
#define SC 8 
#define BUFSZ 2047 
extern int
load_csv_fast(
    const char * const infile,
    uint32_t nC,
    char *str_fld_sep,
    uint32_t chunk_size,
    uint64_t *ptr_nR,
    uint64_t *ptr_file_offset,
    const int *const fldtypes, /* [nC] */
    const bool * const is_trim, /* [nC] */
    bool is_hdr, /* [nC] */
    const bool *  const is_load, /* [nC] */
    const bool * const has_nulls, /* [nC] */
    const int * const width, /* [nC] */
    char **data, /* [nC][chunk_size] */
    uint64_t **nn_data /* [nC][chunk_size] */
    );
