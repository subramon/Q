
extern int
buf_to_file(
   const char *addr,
   size_t size,
   size_t nmemb,
   const char * const file_name
);

typedef struct _file_cleanup_struct {
    char file_name[200];
    int clean;
} file_cleanup_struct;

typedef struct _mmap_rec_type {
  // TODO Change 255 to  Q_MAX_LEN_FILE_NAME
  char file_name[255+1];
    void *map_addr;
    size_t map_len;
    int is_persist;
    int status;
} MMAP_REC_TYPE;

extern MMAP_REC_TYPE *
f_mmap(
   char * const file_name,
   bool is_write
);

extern int64_t 
get_file_size(
	const char * const file_name
	);

extern uint32_t
mix_UI4( 
    uint32_t a
    );

extern uint64_t 
mix_UI8(
    uint64_t a
    );

extern int
rs_mmap(
	const char *file_name,
	char **ptr_mmaped_file,
	size_t *ptr_file_size,
	bool is_write
	);

typedef struct _vec_rec_type {
  uint32_t field_size;
  uint32_t chunk_size;

  uint32_t num_elements;
  uint32_t num_in_chunk;
  uint32_t chunk_num;   

  // TODO Change 255 to  Q_MAX_LEN_FILE_NAME
  char file_name[255+1];

  int status;
  char *chunk;
} VEC_REC_TYPE;

extern int
rand_file_name(
    char *buf,
    size_t bufsz
    );

extern int
chk_field_type(
    const char * const field_type
    );

extern int
vec_new(
    VEC_REC_TYPE *ptr_vec,
    uint32_t field_size,
    uint32_t chunk_size
    );

extern int
vec_check(
    VEC_REC_TYPE *ptr_vec
    );

extern int
vec_free(
    VEC_REC_TYPE *ptr_vec
    );

extern bool 
file_exists (
    const char * constfilename
    );

extern int
vec_set(
    VEC_REC_TYPE *ptr_vec,
    char * const addr, 
    uint32_t len
    );
