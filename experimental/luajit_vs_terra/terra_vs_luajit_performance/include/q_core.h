

typedef struct _mmap_struct {
    void* ptr_mmapped_file;
    size_t file_size;
    int status;
} mmap_struct;


extern mmap_struct*
f_mmap(
   const char * const file_name,
   bool is_write
);


extern int
f_munmap(
    mmap_struct* map
);


extern bool
is_valid_chars_for_num(
      const char * X
      );


extern int
rs_mmap(
 const char *file_name,
 char **ptr_mmaped_file,
 size_t *ptr_file_size,
 bool is_write
 );


extern size_t
get_cell(
    char *X,
    size_t nX,
    size_t xidx,
    bool is_last_col,
    char *buf,
    size_t bufsz
    );

extern int
get_bit(
    unsigned char *x,
    int i
);

extern int
set_bit(
    unsigned char *x,
    int i
);

extern inline int
clear_bit(
    int *x,
    int i
);

extern int
copy_bits(
    unsigned char *dest,
    unsigned char *src,
    int dest_start_index,
    int src_start_index,
    int length
);

extern int
write_bits_to_file(
    FILE * fp,
    unsigned char *src,
    int length,
    int file_size
);

extern int
get_bits_from_array(
    unsigned char *input_arr,
    int *arr,
    int length
);





  extern int
    bin_search_I1(
          const int8_t *X,
          uint64_t nX,
          int8_t key,
          const char * const str_direction,
          int64_t *ptr_pos
        )
    ;





  extern int
    bin_search_I2(
          const int16_t *X,
          uint64_t nX,
          int16_t key,
          const char * const str_direction,
          int64_t *ptr_pos
        )
    ;





  extern int
    bin_search_I4(
          const int32_t *X,
          uint64_t nX,
          int32_t key,
          const char * const str_direction,
          int64_t *ptr_pos
        )
    ;





  extern int
    bin_search_I8(
          const int64_t *X,
          uint64_t nX,
          int64_t key,
          const char * const str_direction,
          int64_t *ptr_pos
        )
    ;





  extern int
    bin_search_F4(
          const float *X,
          uint64_t nX,
          float key,
          const char * const str_direction,
          int64_t *ptr_pos
        )
    ;





  extern int
    bin_search_F8(
          const double *X,
          uint64_t nX,
          double key,
          const char * const str_direction,
          int64_t *ptr_pos
        )
    ;


extern int
txt_to_I1(
      const char * const X,
      int base,
      int8_t *ptr_out
      );


extern int
txt_to_I2(
      const char * const X,
      int base,
      int16_t *ptr_out
      );


extern int
txt_to_I4(
      const char * const X,
      int base,
      int32_t *ptr_out
      );


extern int
txt_to_I8(
      const char * const X,
      int base,
      int64_t *ptr_out
      );


extern int
txt_to_F4(
      const char * const X,
      float *ptr_out
      );


extern int
txt_to_F8(
      const char * const X,
      double *ptr_out
      );
