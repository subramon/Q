extern int 
check_args_is_table(
    lua_State *L
    );
extern int 
get_array_of_strings_from_tbl(
      lua_State *L,
      const char * const key,
      bool *ptr_is_key,
      const char **file_names, // [n] 
      int n
      );
extern int 
get_str_from_tbl(
      lua_State *L,
      const char * const key,
      bool *ptr_is_key,
      const char **ptr_cptr
      );
extern int
get_int_from_tbl(
    lua_State *L, 
    const char * const key,
    bool *ptr_is_key,
    int64_t *ptr_itmp
    );
