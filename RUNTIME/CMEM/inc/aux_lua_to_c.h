extern int 
check_args_is_table(
    lua_State *L
    );
extern int 
get_array_of_ints_from_tbl(
    lua_State *L,
    int stack_index,
    const char * const key,
    bool *ptr_is_key,
    int64_t *out, // allocated before call 
    int n
    );
extern int 
get_array_of_strings_from_tbl(
    lua_State *L,
    int stack_index,
    const char * const key,
    bool *ptr_is_key,
    const char **file_names, // [n] 
    int n
    );
extern int 
get_str_from_tbl(
    lua_State *L,
    int stack_index,
    const char * const key,
    bool *ptr_is_key,
    const char **ptr_cptr
    );
extern int
get_int_from_tbl(
    lua_State *L, 
    int stack_index,
    const char * const key,
    bool *ptr_is_key,
    int64_t *ptr_itmp
    );
extern int
get_bool_from_tbl(
    lua_State *L, 
    int stack_index,
    const char * const key,
    bool *ptr_is_key,
    bool *ptr_val
    );
