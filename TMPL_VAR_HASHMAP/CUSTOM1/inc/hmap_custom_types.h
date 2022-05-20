
typedef struct _hmap_key_t {
  char *str_val;
  uint32_t str_len;
} hmap_key_t; 

typedef struct _hmap_val_t {
  uint64_t min_val;
  uint64_t max_val;
  uint64_t sum_val;
  int cnt;
} hmap_val_t; 

typedef uint32_t hmap_in_val_t;
