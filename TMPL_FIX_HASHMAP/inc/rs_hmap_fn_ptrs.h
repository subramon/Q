#ifndef __RS_HMAP_FN_PTRS
#define __RS_HMAP_FN_PTRS
typedef int (* chk_fn_t)(
    void *ptr_hmap
    );
typedef int (* del_fn_t)(
    void *ptr_hmap, 
    const void * const in_ptr_key, 
    void * in_ptr_val,
    bool *ptr_is_found
    );
typedef void (* destroy_fn_t)(
    void *ptr_hmap
    );
typedef int (* get_fn_t)(
    void *ptr_hmap, 
    const void * const in_ptr_key, 
    void *in_ptr_val,
    bool *ptr_is_found,
    uint32_t *ptr_where_found
    );
typedef int (* freeze_fn_t)(
    void *ptr_hmap, 
    const char * const dir,
    const char * const meta_file_name,
    const char * const bkts_file_name,
    const char * const full_file_name
    );
typedef int (* merge_fn_t)(
    void *ptr_dst_hmap, 
    const void * const ptr_src_hmap
    );
typedef int (* pr_fn_t)(
    void *ptr_hmap, 
    FILE *fp
    );
typedef int (* put_fn_t)(
    void *ptr_hmap, 
    const void * const key, 
    const void * const val
    );
typedef int (* row_dmp_fn_t)(
    void *ptr_hmap, 
    const char * const file_name, 
    void  **ptr_K,
    uint32_t *ptr_nK
    );
// Following need custom implementations
typedef int (*bkt_chk_fn_t )(
    const void * const, 
    int n
    );
typedef bool (*key_cmp_fn_t )(
    const void * const , 
    const void * const 
    );
typedef int (* insert_fn_t)(
    void *ptr_hmap,
    const void * const key,
    const void * const val
    );
typedef int(* key_ordr_fn_t)(
    const void *in1, 
    const void *in2
    );
typedef int(* pr_key_fn_t)(
    void *in_key,
    uint32_t kv_idx,
    FILE *fp
    );
typedef int(* pr_val_fn_t)(
    void *in_val,
    uint32_t kv_idx,
    FILE *fp
    );
typedef int (* resize_fn_t)(
    void *ptr_hmap,
    size_t newsize
    );
typedef int (*set_hash_fn_t )(
    const void * const ptr_key,
    const void * const ptr_hmap
    );
typedef int (*val_update_fn_t )(
    void *, 
    const void * const
    );


#endif // __RS_HMAP_FN_PTRS
