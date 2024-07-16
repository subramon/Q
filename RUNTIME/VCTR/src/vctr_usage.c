#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_get.h"
#include "chnk_rs_hmap_struct.h"
#include "l2_file_name.h"
#include "chnk_is.h"
#include "vctr_name.h"
#include "get_file_size.h"
#include "vctr_usage.h"

extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;
int
vctr_usage(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint64_t *ptr_mem_usage, // mmapped memory 
    uint64_t *ptr_dsk_usage
    )
{
  int status = 0;
  char *lma_file = NULL;char *l2_file = NULL;

  *ptr_mem_usage = 0;
  *ptr_dsk_usage = 0;
  bool vctr_is_found; uint32_t vctr_where_found = ~0;
  vctr_rs_hmap_val_t vctr_val; 
  memset(&vctr_val, 0, sizeof(vctr_rs_hmap_val_t));
  vctr_rs_hmap_key_t vctr_key = vctr_uqid;

  status = vctr_rs_hmap_get(&g_vctr_hmap[tbsp], &vctr_key, 
      &vctr_val, &vctr_is_found, &vctr_where_found);
  if ( !vctr_is_found ) {  /* silent failure */ return 1; }
  // how much mem/dsk used at vector level 
  if ( vctr_val.is_lma ) { 
    lma_file = l2_file_name(tbsp, vctr_uqid, ((uint32_t)~0));
    if ( lma_file == NULL ) { go_BYE(-1); }
    *ptr_dsk_usage = get_file_size(lma_file); 
    *ptr_mem_usage = vctr_val.nX; 
    free_if_non_null(lma_file);
  }
  // how much mem/dsk used at chunk level
  for ( uint32_t chnk_idx = vctr_val.min_chnk_idx; 
      chnk_idx <= vctr_val.max_chnk_idx; chnk_idx++ ) {
    bool chnk_is_found; uint32_t chnk_where_found = ~0;
    status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found, 
        &chnk_where_found);
    cBYE(status);
    if ( !chnk_is_found ) { continue; } // NOTE Not throwing error
    chnk_rs_hmap_val_t chnk_val = 
      g_chnk_hmap[tbsp].bkts[chnk_where_found].val;
      // if data not in L2, must be in L1 
    if ( ( chnk_val.l1_mem == NULL ) && ( chnk_val.l2_exists == false ) 
      && ( vctr_val.is_lma == false ) ) {
      go_BYE(-1);
    }
    if ( chnk_val.l1_mem != NULL ) {
      if ( chnk_val.size == 0 ) { go_BYE(-1); } 
      *ptr_mem_usage += chnk_val.size;
    }
    if ( chnk_val.l2_exists ) { 
      // check that file exists 
      l2_file = l2_file_name(tbsp, vctr_uqid, chnk_idx);
      int64_t filesz = get_file_size(l2_file);
      if ( filesz <= 0 ) { go_BYE(-1); } 
      *ptr_dsk_usage += filesz;
      free_if_non_null(l2_file);
    }
  }
BYE:
  free_if_non_null(lma_file);
  free_if_non_null(l2_file);
  return status;
}
// For debugging. Prints vectors that are using memory or disk 
int
vctr_hogs(
    const char * const mode
    )
{
  int status = 0;
  printf("uqid,name");
  if ( ( mode == NULL ) || ( *mode == '\0' ) ) { 
    printf(",mem_usage,dsk_usage\n");
  }
  else { 
    if ( strcasecmp(mode, "mem") == 0 ) {
      printf(",mem_usage\n");
    }
    else if ( strcasecmp(mode, "dsk") == 0 ) {
      printf(",dsk_usage\n");
    }
    else {
      go_BYE(-1);
    }
  }

  uint32_t tbsp = 0; // only for your own tablespace 
  for ( uint32_t i = 0; i < g_vctr_hmap[tbsp].size; i++ ) {
    if ( !g_vctr_hmap[tbsp].bkt_full[i] ) { continue; } 
    vctr_rs_hmap_key_t key = g_vctr_hmap[tbsp].bkts[i].key;
    uint32_t vctr_uqid = key;
    //--- Check usage statistics
    uint64_t mem, dsk; 
    status = vctr_usage(tbsp, vctr_uqid, &mem, &dsk); cBYE(status);
    char * name = vctr_get_name(tbsp, vctr_uqid); 
    if ( ( mode == NULL ) || ( *mode == '\0' ) ) { 
      printf("%u:[%s]%" PRIu64",%"PRIu64"\n",
          vctr_uqid, name == NULL ? "anonymous" : name, mem, dsk);
    }
    else { 
      if ( strcasecmp(mode, "mem") == 0 ) {
        if ( mem != 0 ) { 
        printf("%u:[%s]%" PRIu64"\n", 
            vctr_uqid, name == NULL ? "anonymous" : name, mem); 
        }
      }
      else if ( strcasecmp(mode, "dsk") == 0 ) {
        if ( dsk != 0 ) { 
        printf("%u:[%s]%" PRIu64"\n", 
            vctr_uqid, name == NULL ? "anonymous" : name, dsk); 
        }
      }
      else {
        go_BYE(-1);
      }
    }
  }
BYE:
  return status;
}
