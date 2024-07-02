#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "cmem_struct.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "rs_mmap.h"
#include "rdtsc.h"
#include "file_exists.h"
#include "l2_file_name.h"
#include "rs_mmap.h"
#include "vctr_is.h"
#include "chnk_del.h"
#include "vctr_del.h"
#include "vctr_lma_access.h"

extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

int 
vctr_unget_lma_X_nX(
    vctr_rs_hmap_val_t *ptr_val,
    char **ptr_X,
    size_t *ptr_nX
    )
{
  int status = 0;
  char *X = *ptr_X;
  size_t nX = *ptr_nX;

  if ( ptr_val->num_readers == 0 ) { go_BYE(-1); } 
  ptr_val->num_readers--; 
  if ( ptr_val->num_readers == 0 ) { 
    munmap(X, nX);
    ptr_val->X = NULL;
    ptr_val->nX = 0;
  }
BYE:
  return status;
}
//------------------------------
int
vctr_get_lma_X_nX(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    vctr_rs_hmap_val_t *ptr_val,
    char **ptr_X,
    size_t *ptr_nX
    )
{
  int status = 0; 
  char *X = NULL; size_t nX = 0;
  char *lma_file = NULL; 

  *ptr_X = NULL; *ptr_nX = 0;
  if ( ptr_val->num_readers > 0 ) { 
    X = ptr_val->X;
    nX = ptr_val->nX;
  }
  else {
    lma_file = l2_file_name(tbsp, vctr_uqid, ((uint32_t)~0));
    if ( lma_file == NULL ) { go_BYE(-1); }
    status = rs_mmap(lma_file, &X, &nX, 0); cBYE(status);
    ptr_val->X  = X;
    ptr_val->nX = nX;
  }
  ptr_val->num_readers++; 
  *ptr_X = X; *ptr_nX = nX;
BYE:
  free_if_non_null(lma_file);
  return status;
}


int
vctr_get_lma_read(
    uint32_t tbsp,
    uint32_t uqid,
    CMEM_REC_TYPE *ptr_cmem
    )
{
  int status = 0;
  bool is_found; uint32_t where_found = ~0;
  char *lma_file = NULL;

  memset(ptr_cmem, 0, sizeof(CMEM_REC_TYPE));
  status = vctr_is(tbsp, uqid, &is_found, &where_found); cBYE(status);
  if ( !is_found ) { goto BYE; }
  vctr_rs_hmap_val_t val = g_vctr_hmap[tbsp].bkts[where_found].val;
  if ( !val.is_lma ) { go_BYE(-1); } 
  if ( val.num_writers != 0 ) { go_BYE(-1); }

  char * X  = val.X;
  size_t nX = val.nX;
  //-------------------------------------
  if ( ( X == NULL ) || ( nX == 0 ) )  {
    lma_file = l2_file_name(tbsp, uqid, ((uint32_t)~0));
    if ( lma_file == NULL ) { go_BYE(-1); }
    if ( !file_exists(lma_file) ) { go_BYE(-1); }
  // note difference in rs_mmap() call between read and write 
    status = rs_mmap(lma_file, &X, &nX, 0); cBYE(status);
    g_vctr_hmap[tbsp].bkts[where_found].val.X  = X;
    g_vctr_hmap[tbsp].bkts[where_found].val.nX = nX;
  }
  g_vctr_hmap[tbsp].bkts[where_found].val.num_readers++; 

  ptr_cmem->data = X; 
  ptr_cmem->size = nX;
  ptr_cmem->is_foreign = true;
BYE:
  free_if_non_null(lma_file); 
  return status;
}

int
vctr_get_lma_write(
    uint32_t tbsp,
    uint32_t uqid,
    CMEM_REC_TYPE *ptr_cmem
    )
{
  int status = 0;
  bool is_found; uint32_t where_found = ~0;
  char *lma_file = NULL;
  char *X = NULL; size_t nX = 0; 

  // Cannot write to lma from a different tablespace 
  if ( tbsp != 0 ) { go_BYE(-1); } 
  memset(ptr_cmem, 0, sizeof(CMEM_REC_TYPE));
  status = vctr_is(tbsp, uqid, &is_found, &where_found); cBYE(status);
  if ( !is_found ) { goto BYE; }
  vctr_rs_hmap_val_t val = g_vctr_hmap[tbsp].bkts[where_found].val;
  if ( !val.is_lma ) { go_BYE(-1); } 
  if ( val.num_writers != 0 ) { go_BYE(-1); }
  if ( val.num_readers != 0 ) { go_BYE(-1); }

  X = val.X;
  nX = val.nX;
  //-------------------------------------
  if ( ( X == NULL ) || ( nX == 0 ) )  { 
    lma_file = l2_file_name(tbsp, uqid, ((uint32_t)~0));
    if ( lma_file == NULL ) { go_BYE(-1); }
    if ( !file_exists(lma_file) ) { go_BYE(-1); }
    // note difference in rs_mmap() call between read and write 
    status = rs_mmap(lma_file, &X, &nX, 1); cBYE(status);
    g_vctr_hmap[tbsp].bkts[where_found].val.X  = X;
    g_vctr_hmap[tbsp].bkts[where_found].val.nX = nX;
    g_vctr_hmap[tbsp].bkts[where_found].val.num_writers++; 
  }

  ptr_cmem->data = X; 
  ptr_cmem->size = nX;
  ptr_cmem->is_foreign = true;

BYE:
  free_if_non_null(lma_file); 
  return status;
}

int
vctr_unget_lma_read(
    uint32_t tbsp,
    uint32_t uqid
    )
{
  int status = 0;
  bool is_found; uint32_t where_found = ~0;

  status = vctr_is(tbsp, uqid, &is_found, &where_found); cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  vctr_rs_hmap_val_t val = g_vctr_hmap[tbsp].bkts[where_found].val;
  if ( !val.is_lma ) { go_BYE(-1); } 
  if ( val.num_writers != 0 ) { go_BYE(-1); }
  if ( val.num_readers == 0 ) { go_BYE(-1); }
  if ( ( val.X == NULL ) || ( val.nX == 0 ) )  { go_BYE(-1); }

  g_vctr_hmap[tbsp].bkts[where_found].val.num_readers--; 
  if ( g_vctr_hmap[tbsp].bkts[where_found].val.num_readers == 0 ) { 
    munmap(val.X, val.nX); 
    g_vctr_hmap[tbsp].bkts[where_found].val.X = NULL;
    g_vctr_hmap[tbsp].bkts[where_found].val.nX = 0;
  }
BYE:
  return status;
}

int
vctr_unget_lma_write(
    uint32_t tbsp,
    uint32_t uqid
    )
{
  int status = 0;
  bool is_found; uint32_t where_found = ~0;

  // Cannot write to lma from a different tablespace 
  if ( tbsp != 0 ) { go_BYE(-1); } 
  status = vctr_is(tbsp, uqid, &is_found, &where_found); cBYE(status);
  if ( !is_found ) { goto BYE; }
  vctr_rs_hmap_val_t val = g_vctr_hmap[tbsp].bkts[where_found].val;
  if ( !val.is_lma ) { go_BYE(-1); } 
  if ( val.num_writers != 1 ) { go_BYE(-1); }
  if ( val.num_readers != 0 ) { go_BYE(-1); }
  if ( ( val.X == NULL ) || ( val.nX == 0 ) )  { go_BYE(-1); }

  g_vctr_hmap[tbsp].bkts[where_found].val.num_writers--; 
  munmap(val.X, val.nX); 
  g_vctr_hmap[tbsp].bkts[where_found].val.X = NULL;
  g_vctr_hmap[tbsp].bkts[where_found].val.nX = 0;

BYE:
  return status;
}
