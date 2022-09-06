#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "vctr_del.h"

extern vctr_rs_hmap_t g_vctr_hmap;
extern chnk_rs_hmap_t g_chnk_hmap;

extern uint64_t g_mem_used;

int
vctr_del(
    uint32_t uqid,
    bool *ptr_is_found
    )
{
  int status = 0;
  printf("Freeing %u \n", uqid);
  vctr_rs_hmap_key_t key = uqid; 
  vctr_rs_hmap_val_t val;
  status = g_vctr_hmap.del(&g_vctr_hmap, &key, &val, ptr_is_found); 
  cBYE(status);
  if ( !*ptr_is_found ) { goto BYE; }
  //-------------------------------------------
  if ( val.num_elements > 0 ) { 
    bool is_found;
    if ( val.num_chunks == 0 ) { go_BYE(-1); }
    for ( uint32_t i = 0; i < val.num_chunks; i++ ) { 
      if ( g_chnk_hmap.nitems == 0 ) { go_BYE(-1); }
      chnk_rs_hmap_key_t chnk_key = { .vctr_uqid = uqid, .chnk_idx = i };
      chnk_rs_hmap_val_t chnk_val;
      status = g_chnk_hmap.del(&g_chnk_hmap, &chnk_key, &chnk_val, 
          &is_found); 
      cBYE(status);
      if ( chnk_val.l1_mem != NULL ) { 
        free_if_non_null(chnk_val.l1_mem);
        uint64_t sz = val.chnk_size * val.width;
        if ( sz == 0 ) { go_BYE(-1); } 
        if ( sz > g_mem_used ) { go_BYE(-1); } 
        __atomic_sub_fetch(&g_mem_used, sz, 0);
      }
      if ( chnk_val.l2_mem[0] != '\0' ) { unlink(chnk_val.l2_mem); }
      if ( chnk_val.l3_mem[0] != '\0' ) { unlink(chnk_val.l3_mem); }
      if ( !is_found ) { go_BYE(-1); }
    }
  }
BYE:
  return status;
}
