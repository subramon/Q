#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "vctr_lma_access.h"
#include "vctr_get_chunk.h"
#include "chnk_get_data.h"
#include "rdtsc.h"

extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

int
vctr_get_chunk(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t *ptr_num_in_chunk, // number in chunk
    bool *ptr_yes_vec_no_chunk
    )
{
  int status = 0;
  bool vctr_is_found = false, chnk_is_found;
  uint32_t vctr_where_found, chnk_where_found;
  uint32_t chnk_size, width, max_num_in_chnk;
  bool is_write = false; // TODO P3 Handle case when this is true 

  *ptr_yes_vec_no_chunk = false;
  if ( ptr_cmem == NULL ) { go_BYE(-1); } 
  *ptr_num_in_chunk = 0;
  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }

  width  = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.width;
  max_num_in_chnk = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.max_num_in_chnk;
  chnk_size = width * max_num_in_chnk;

  //-------------------------------
  // Changed my mind on following
  /* DECIDED NOT TO RELY ON LMA file backup. Each chunk must
   * have its own backup. I may be wrong on this one. Time will tell
   */
  if ( g_vctr_hmap[tbsp].bkts[vctr_where_found].val.is_lma ) { 
    status = vctr_get_chunk_lma(
        &(g_vctr_hmap[tbsp].bkts[vctr_where_found].val),
        tbsp, vctr_uqid, chnk_idx, ptr_cmem, ptr_num_in_chunk);
    cBYE(status);
    goto BYE;
  }

  //-------------------------------
  status = chnk_is(tbsp, vctr_uqid, chnk_idx, 
      &chnk_is_found, &chnk_where_found);
  cBYE(status);
  if ( chnk_is_found == false ) { 
    *ptr_yes_vec_no_chunk = true; status = -1; goto BYE;
  }
  //-----------------------------------------------------
  char *data = chnk_get_data(tbsp, chnk_where_found, is_write); 
  if ( data == NULL ) { go_BYE(-1); }

  memset(ptr_cmem, 0, sizeof(CMEM_REC_TYPE));
  ptr_cmem->data  = data;
  ptr_cmem->qtype = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.qtype; 
  ptr_cmem->size  = chnk_size;
  ptr_cmem->is_foreign  = true;
  ptr_cmem->is_stealable  = false;
  // DONE in chnk_get_data: g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_readers++;
  *ptr_num_in_chunk = g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_elements; 
  // update touch time 
  uint64_t touch_time = RDTSC();
  __atomic_store(&(g_chnk_hmap[tbsp].bkts[chnk_where_found].val.touch_time),
      &touch_time, 0);
BYE:
  if ( status < 0 ) { 
    if ( *ptr_yes_vec_no_chunk ) { 
      /* quiet failure
      printf("Chunk %d of %s unavailable \n", chnk_idx, 
          g_vctr_hmap[tbsp].bkts[vctr_where_found].val.name);
          */
    }
    else {
      WHEREAMI;
    }
  }
  return status;
}

int
vctr_unget_chunk(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    int in_chnk_idx
    )
{
  int status = 0;
  bool vctr_is_found, chnk_is_found;
  uint32_t vctr_where_found, chnk_where_found;

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }

  // DECIDED AGAINST USING LMA FOR CHUNK ACCESS 
  // Changed my mind on above
  vctr_rs_hmap_val_t *ptr_val = 
     &g_vctr_hmap[tbsp].bkts[vctr_where_found].val;
  if ( ptr_val->is_lma ) {
    if ( ptr_val->num_readers == 0 ) { go_BYE(-1); }
    ptr_val->num_readers--;
    if ( ptr_val->num_readers == 0 ) { 
      munmap(ptr_val->X, ptr_val->nX);
      ptr_val->X = NULL; ptr_val->nX = 0; 
    }
    goto BYE;
    // TODO P2 update touch time  for vector similar to chunk below 
  }

  uint32_t chnk_idx = (uint32_t)in_chnk_idx;
  status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found, 
      &chnk_where_found);
  cBYE(status);
  if ( chnk_is_found == false ) { 
    go_BYE(-1); 
  } 
  chnk_rs_hmap_val_t *ptr_chnk = 
    &g_chnk_hmap[tbsp].bkts[chnk_where_found].val;
  if ( ptr_chnk->num_readers == 0 ) { go_BYE(-1); }
  ptr_chnk->num_readers--;
  // update touch time 
  uint64_t touch_time = RDTSC();
  __atomic_store(&(ptr_chnk->touch_time), &touch_time, 0); 
BYE:
  return status;
}

// This function was needed if we wanted to get chunk data from lma file
// Decided against it for now 
// NOTE: Changed my mind on above
int
vctr_get_chunk_lma(
    vctr_rs_hmap_val_t *ptr_val,
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t *ptr_num_in_chunk // number in chunk
    )
{
  int status = 0;
  char *X = NULL; size_t nX = 0;

  if ( ptr_val->is_lma == false ) { go_BYE(-1); }
  if ( ptr_val->num_writers != 0 ) { go_BYE(-1); }
  status = vctr_get_lma_X_nX(tbsp, vctr_uqid, ptr_val, &X, &nX);
  cBYE(status);
  //---------------------------------------------------
  uint32_t width = ptr_val->width;
  uint32_t max_num_in_chnk = ptr_val->max_num_in_chnk;
  size_t chunk_size;
  if ( ptr_val->qtype == B1 ) { 
    chunk_size = max_num_in_chnk / 8;
  }
  else { 
    chunk_size = width * max_num_in_chnk;
  }
  size_t offset = chunk_size * chnk_idx;
  if ( offset > nX ) { go_BYE(-1); }
  // TODO P3 FIX THIS CHECK if ((offset + chunk_size) > nX ) { go_BYE(-1); }
  ptr_cmem->data = X + offset;
  // The min(..) is to handle case of last chunk which has 
  // fewer elements than max_num_in_chunk
  ptr_cmem->size = mcr_min(nX - offset, chunk_size);
  ptr_cmem->is_foreign = true;

  *ptr_num_in_chunk = ptr_cmem->size / width;

BYE:
  return status;
}
