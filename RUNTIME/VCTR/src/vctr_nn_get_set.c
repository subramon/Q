#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_get.h"
#include "vctr_is.h"
#include "chnk_del.h"
#include "vctr_nn_get_set.h"

extern vctr_rs_hmap_t *g_vctr_hmap;

int
vctr_set_nn_vec(
    uint32_t base_tbsp,
    uint32_t base_uqid,
    uint32_t nn_tbsp,
    uint32_t nn_uqid
    )
{
  int status = 0;
  if ( base_tbsp != 0 ) { go_BYE(-1); }
  if ( base_tbsp != nn_tbsp ) { go_BYE(-1); }
  if ( base_uqid == nn_uqid ) { go_BYE(-1); }
  if ( base_uqid == 0 ) { go_BYE(-1); }
  if ( nn_uqid == 0 ) { go_BYE(-1); }
  //-------------------------------
  bool base_is_found; uint32_t base_where = ~0;
  vctr_rs_hmap_key_t base_key = base_uqid;
  vctr_rs_hmap_val_t base_val; 
  status = vctr_rs_hmap_get(&g_vctr_hmap[base_tbsp], &base_key, &base_val, 
      &base_is_found, &base_where);
  if ( !base_is_found ) { go_BYE(-1); }
  vctr_rs_hmap_val_t *ptr_base_val = 
    &(g_vctr_hmap[base_tbsp].bkts[base_where].val);

  bool nn_is_found; uint32_t nn_where = ~0;
  vctr_rs_hmap_key_t nn_key = nn_uqid;
  vctr_rs_hmap_val_t nn_val; 
  status = vctr_rs_hmap_get(&g_vctr_hmap[nn_tbsp], &nn_key, &nn_val, 
      &nn_is_found, &nn_where);
  if ( !nn_is_found ) { go_BYE(-1); }
  vctr_rs_hmap_val_t *ptr_nn_val = 
    &(g_vctr_hmap[nn_tbsp].bkts[nn_where].val);

  // checks 
  if ( ptr_base_val->has_nn ) { go_BYE(-1); }
  if ( ptr_base_val->nn_key != 0 ) { go_BYE(-1); }
  if ( ptr_nn_val->has_parent ) { go_BYE(-1); }
  if ( ( ptr_nn_val->qtype != BL ) && ( ptr_nn_val->qtype != B1 ) ) {
    go_BYE(-1);
  }
  ptr_base_val->has_nn = true;
  ptr_base_val->nn_key = nn_uqid;
  ptr_nn_val->has_parent = true;
  ptr_nn_val->parent_key = base_uqid;
BYE:
  return status;
}

int
vctr_get_nn_vec(
    uint32_t base_tbsp,
    uint32_t base_uqid,
    bool *ptr_has_nn,
    uint32_t *ptr_nn_uqid
    )
{
  int status = 0;
  if ( base_tbsp != 0 ) { go_BYE(-1); }
  if ( base_uqid == 0 ) { go_BYE(-1); }
  //-------------------------------
  bool base_is_found; uint32_t base_where = ~0;
  vctr_rs_hmap_key_t base_key = base_uqid;
  vctr_rs_hmap_val_t base_val; 
  status = vctr_rs_hmap_get(&g_vctr_hmap[base_tbsp], &base_key, &base_val, 
      &base_is_found, &base_where);
  if ( !base_is_found ) { go_BYE(-1); }
  *ptr_has_nn = base_val.has_nn;
  *ptr_nn_uqid = base_val.nn_key;
BYE:
  return status;
}

int
vctr_brk_nn_vec(
    uint32_t base_tbsp,
    uint32_t base_uqid,
    bool del_nn
    )
{
  int status = 0;
  if ( base_tbsp != 0 ) { go_BYE(-1); }
  if ( base_uqid == 0 ) { go_BYE(-1); }
  //-------------------------------
  bool base_is_found; uint32_t base_where = ~0;
  vctr_rs_hmap_key_t base_key = base_uqid;
  vctr_rs_hmap_val_t base_val; 
  status = vctr_rs_hmap_get(&g_vctr_hmap[base_tbsp], &base_key, &base_val, 
      &base_is_found, &base_where);
  if ( !base_is_found ) { go_BYE(-1); }
  if ( !base_val.has_nn  ) { return status; } // silent failure

  uint32_t nn_uqid = base_val.nn_key;
  bool nn_is_found; uint32_t nn_where = ~0;
  vctr_rs_hmap_key_t nn_key = nn_uqid;
  vctr_rs_hmap_val_t nn_val; 
  status = vctr_rs_hmap_get(&g_vctr_hmap[base_tbsp], &nn_key, &nn_val, 
      &nn_is_found, &nn_where);
  if ( !nn_is_found ) { go_BYE(-1); }


  // now we can do the breaking 
  g_vctr_hmap[base_tbsp].bkts[base_where].val.has_nn = false;
  g_vctr_hmap[base_tbsp].bkts[base_where].val.nn_key = 0;

  g_vctr_hmap[base_tbsp].bkts[nn_where].val.has_parent = false;
  g_vctr_hmap[base_tbsp].bkts[nn_where].val.parent_key = 0;

  if ( del_nn ) { 
    printf("Deleting nn vector\n"); 
    bool is_found; 
    status = vctr_del(base_tbsp, nn_uqid, &is_found);  cBYE(status);
    if ( !is_found ) { go_BYE(-1); }
  }
BYE:
  return status;
}
