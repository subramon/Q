typedef struct _hmap_kv_t { 
  hmap_key_t key;
  hmap_val_t val;
} hmap_kv_t;

extern int
hmap_bindmp(
    hmap_t *ptr_hmap, 
    hmap_kv_t **ptr_K,
    uint32_t *ptr_nK
    );
