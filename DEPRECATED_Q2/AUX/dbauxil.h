extern int get_fld_sz(
    const char *fldtype,
    FLD_TYPE *ptr_fldtype,
    int *ptr_len
    );
extern int
get_nn_data(
    const char *fld, 
    int has_null_fld, 
    char **ptr_nn_X, 
    size_t *ptr_nn_nX
    );
int
get_aux_data(
    const char *fld, 
    const char *str_fldtype,
    const char *auxtype,
    char **ptr_aux_X, 
    size_t *ptr_aux_nX
    );
