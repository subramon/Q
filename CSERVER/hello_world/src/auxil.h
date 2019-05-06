extern int
stoF4(
      const char *X,
      float *ptr_valF4
      );
extern int
stoI4(
      const char *X,
      int32_t *ptr_Y
      );
extern int
stoI8(
      const char *X,
      int64_t *ptr_Y
      );
extern uint64_t 
timestamp(
    void
    );
extern uint32_t get_time_sec(
    void
    );
extern uint64_t get_time_usec(
    void
    );
extern uint64_t 
RDTSC(
    void
    );
extern bool
is_valid_url_char(
    char c
    );
extern int
mk_json_output(
    char *api, 
    char *args, 
    char *err, 
    char *out
    );
extern int
add_to_buf(
    char *in,
    const char *label,
    char *out,
    int sz_out,
    int *ptr_n_out
    );
extern bool 
isfile (
    const char * const filename
    );
extern bool 
isdir (
    const char * const dirname
    );
