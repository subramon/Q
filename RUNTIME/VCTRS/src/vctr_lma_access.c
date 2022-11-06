#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "cmem_struct.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "l2_file_name.h"
#include "rs_mmap.h"
#include "rdtsc.h"
#include "file_exists.h"
#include "vctr_is.h"
#include "chnk_del.h"
#include "vctr_del.h"
#include "vctr_lma_access.h"

extern vctr_rs_hmap_t g_vctr_hmap[Q_MAX_NUM_TABLESPACES];
extern chnk_rs_hmap_t g_chnk_hmap[Q_MAX_NUM_TABLESPACES];

char *
vctr_steal_lma(
    uint32_t tbsp,
    uint32_t uqid
    )
{
  int status = 0;
  bool is_found; uint32_t where_found;
  char *lma_file = NULL;
  char *new_file = NULL;

  // Cannot steal lma from a different tablespace
  if ( tbsp != 0 ) { go_BYE(-1); } 

  status = vctr_is(tbsp, uqid, &is_found, &where_found); cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  vctr_rs_hmap_val_t val = g_vctr_hmap[tbsp].bkts[where_found].val;
  if ( !val.is_lma )          { go_BYE(-1); } 
  if ( val.num_writers != 0 ) { go_BYE(-1); }
  if ( val.num_readers != 0 ) { go_BYE(-1); }
  if ( val.X           != NULL ) { go_BYE(-1); }
  if ( val.nX          != 0 ) { go_BYE(-1); }

  lma_file = l2_file_name(tbsp, uqid, ((uint32_t)~0));
  if ( lma_file == NULL ) { go_BYE(-1); }
  if ( !file_exists(lma_file) ) { go_BYE(-1); }
  new_file = malloc(strlen(lma_file) + 64);
  return_if_malloc_failed(new_file);
  sprintf(new_file, "%s_%" PRIu64 "", lma_file, RDTSC());
  status = rename(lma_file, new_file); cBYE(status);
  g_vctr_hmap[tbsp].bkts[where_found].val.is_lma = false; 
BYE:
  free_if_non_null(lma_file);
  if ( status == 0 ) { return new_file; } else { return NULL; } 
}

int
vctr_get_lma_read(
    uint32_t tbsp,
    uint32_t uqid,
    CMEM_REC_TYPE *ptr_cmem
    )
{
  int status = 0;
  bool is_found; uint32_t where_found;
  char *lma_file = NULL;

  memset(ptr_cmem, 0, sizeof(CMEM_REC_TYPE));
  status = vctr_is(tbsp, uqid, &is_found, &where_found); cBYE(status);
  if ( !is_found ) { goto BYE; }
  vctr_rs_hmap_val_t val = g_vctr_hmap[tbsp].bkts[where_found].val;
  if ( !val.is_lma ) { go_BYE(-1); } 
  if ( val.num_writers != 0 ) { go_BYE(-1); }

  char * X  = val.X;
  size_t nX = val.nX;
  if ( ( X == NULL ) || ( nX == 0 ) )  {
    //-------------------------------------
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
  bool is_found; uint32_t where_found;
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

  if ( ( val.X != NULL ) || ( val.nX != 0 ) )  { go_BYE(-1); }
  //-------------------------------------
  lma_file = l2_file_name(tbsp, uqid, ((uint32_t)~0));
  if ( lma_file == NULL ) { go_BYE(-1); }
  if ( !file_exists(lma_file) ) { go_BYE(-1); }
  // note difference in rs_mmap() call between read and write 
  status = rs_mmap(lma_file, &X, &nX, 1); cBYE(status);
  g_vctr_hmap[tbsp].bkts[where_found].val.X  = X;
  g_vctr_hmap[tbsp].bkts[where_found].val.nX = nX;
  g_vctr_hmap[tbsp].bkts[where_found].val.num_writers++; 

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
  bool is_found; uint32_t where_found;

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
  bool is_found; uint32_t where_found;

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
