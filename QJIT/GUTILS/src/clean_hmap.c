#include "q_incs.h"
#include "q_macros.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "vctr_del.h"
#include "clean_hmap.h"
// We need to delete any vectors that had *NOT* been persisted
int
clean_hmap(
    vctr_rs_hmap_t *vctr_hmap,
    chnk_rs_hmap_t *chnk_hmap,
    uint32_t tbsp,
    int *ptr_num_to_delete
    )
{
  int status = 0;
  uint32_t *uqids_to_del = NULL; 
  vctr_rs_hmap_bkt_t *bkts = vctr_hmap->bkts; 
  bool *bkt_full =  vctr_hmap->bkt_full; 
  // STEP 1: Count how many to be deleted 
  int num_to_delete = 0;
  for ( uint32_t i = 0; i < vctr_hmap->size; i++ ) { 
    if ( !bkt_full[i] ) { continue; } 
    if ( bkts[i].val.is_persist == true ) { continue; }
    num_to_delete++;
  }
  if ( num_to_delete > 0 )  {
    // STEP 2: Assemble vctr_uqid's of those to be deleted
    printf("Ready to delete %u vectors\n", num_to_delete);
    uqids_to_del = malloc(num_to_delete * sizeof(uint32_t));
    return_if_malloc_failed(uqids_to_del); 
    num_to_delete = 0;
    for ( uint32_t i = 0; i < vctr_hmap->size; i++ ) { 
      if ( !bkt_full[i] ) { continue; } 
      if ( bkts[i].val.is_persist == true ) { continue; }
      uqids_to_del[num_to_delete++] = bkts[i].key;
    }
    // STEP 3: now go ahead and delete them 
    for ( int i = 0; i < num_to_delete; i++ ) { 
      bool is_found = false;
      status = vctr_del(tbsp, uqids_to_del[i], &is_found); cBYE(status);
      if ( !is_found ) { go_BYE(-1); } 
      // printf("During import, deleted vector %u \n", vctr_uqid);
    }
  }
  //-------------------
  for ( uint32_t i = 0; i < vctr_hmap->size; i++ ) { 
    if ( !bkt_full[i] ) { continue; } 
    bkts[i].val.X = NULL;
    bkts[i].val.nX = 0;
    bkts[i].val.is_killable = false;
    bkts[i].val.is_memo = false;
    bkts[i].val.is_early_freeable = false;
    bkts[i].val.num_readers = 0;
    bkts[i].val.num_writers = 0;
  }
  chnk_rs_hmap_bkt_t *chnk_bkts = chnk_hmap->bkts; 
  bool *chnk_bkt_full =  chnk_hmap->bkt_full; 
  for ( uint32_t i = 0; i < chnk_hmap->size; i++ ) { 
    if ( !chnk_bkt_full[i] ) { continue; } 
    chnk_bkts[i].val.l1_mem = NULL; 
    chnk_bkts[i].val.num_readers = 0; 
  }
  printf("Deleted %d vectors that were not persisted\n", num_to_delete);
  //-----------------------------------
  *ptr_num_to_delete = num_to_delete;
BYE:
  free_if_non_null(uqids_to_del);
  return status;
}
