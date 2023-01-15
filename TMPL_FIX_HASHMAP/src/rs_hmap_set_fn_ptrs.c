#include "aux.h"
#include "set_probe_loc.h"

#include "rs_hmap_common.h"
#include "${tmpl}_rs_hmap_struct.h"
#include "rsx_set_hash.h"
#include "_rs_hmap_set_fn_ptrs.h"

// This is an internal (local) call 
int
${tmpl}_rs_hmap_set_fn_ptrs(
    ${tmpl}_rs_hmap_t *H
    )
{
  int status = 0;
  H->config.so_handle = dlopen(H->config.so_file, RTLD_NOW); 
  if ( H->config.so_handle == NULL ) { 
    fprintf(stderr, "Unable to open %s \n", H->config.so_file); 
    go_BYE(-1); 
  }

  // external exposure for following
  H->chk = (chk_fn_t) dlsym(H->config.so_handle, "rs_hmap_chk"); 
  H->del = (del_fn_t) dlsym(H->config.so_handle, "rs_hmap_del"); 
  H->destroy = (destroy_fn_t) dlsym(H->config.so_handle,"rs_hmap_destroy"); 
  H->freeze = (freeze_fn_t) dlsym(H->config.so_handle,"rs_hmap_freeze"); 
  H->get = (get_fn_t) dlsym(H->config.so_handle, "rs_hmap_get"); 
  H->merge = (merge_fn_t) dlsym(H->config.so_handle, "rs_hmap_merge"); 
  H->pr  = (pr_fn_t) dlsym(H->config.so_handle, "rs_hmap_pr"); 
  H->put = (put_fn_t) dlsym(H->config.so_handle, "rs_hmap_put"); 
  H->row_dmp = (row_dmp_fn_t) dlsym(H->config.so_handle,"rs_hmap_row_dmp"); 

  H->insert = (insert_fn_t) dlsym(H->config.so_handle, "rs_hmap_insert"); 
  H->resize = (resize_fn_t) dlsym(H->config.so_handle, "rs_hmap_resize"); 
  //--------------------------------------------------------
  // custom implementations for following
  H->bkt_chk = (bkt_chk_fn_t) dlsym(H->config.so_handle, "rsx_bkt_chk"); 
  H->key_cmp = (key_cmp_fn_t) dlsym(H->config.so_handle, "rsx_key_cmp"); 
  H->key_ordr = (key_ordr_fn_t) dlsym(H->config.so_handle, "rsx_key_ordr"); 
  H->pr_key = (pr_key_fn_t) dlsym(H->config.so_handle, "rsx_pr_key"); 
  H->pr_val = (pr_val_fn_t) dlsym(H->config.so_handle, "rsx_pr_val"); 
  H->val_update = (val_update_fn_t) dlsym(H->config.so_handle, "rsx_val_update"); 
  H->set_hash = (set_hash_fn_t) dlsym(H->config.so_handle, "rsx_set_hash"); 
  //--------------------------------------------------------
  H->start_check_val = 123456789;
  H->stop_check_val  = 987654321;

BYE:
  return status;
}
