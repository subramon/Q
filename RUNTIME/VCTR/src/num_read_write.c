#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "num_read_write.h"

extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

int
vctr_get_num_rw(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t *ptr_num,
    const char * rw
    )
{
  int status = 0; 
  bool vctr_is_found;
  uint32_t vctr_where_found;

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }
  if ( strcmp(rw, "read") == 0 ) { 
    *ptr_num = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.num_readers;
  }
  else if ( strcmp(rw, "write") == 0 ) { 
    *ptr_num = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.num_writers;
  }
  else {
    go_BYE(-1);
  }
BYE:
  return status;
}
//-------------------------------------------------
int
vctr_get_num_readers(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t *ptr_num
    )
{
  int status = 0;
  status = vctr_get_num_rw(tbsp, vctr_uqid, ptr_num, "read");
BYE:
  return status;
}
//-------------------------------------------------
int
vctr_get_num_writers(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t *ptr_num
    )
{
  int status = 0;
  status = vctr_get_num_rw(tbsp, vctr_uqid, ptr_num, "write");
BYE:
  return status;
}
//------------------------------------------
int
chnk_get_num_readers(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    uint32_t *ptr_num
    )
{
  int status = 0;
  status = chnk_get_num_rw(tbsp, vctr_uqid, chnk_idx, ptr_num, "read");
BYE:
  return status;
}
//----------------------------------------------------------
int
chnk_get_num_writers(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    uint32_t *ptr_num
    )
{
  int status = 0;
  status = chnk_get_num_rw(tbsp, vctr_uqid, chnk_idx, ptr_num, "write");
BYE:
  return status;
}
//----------------------------------------------------------
int
chnk_get_num_rw(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    uint32_t *ptr_num,
    const char * rw
    )
{
  int status = 0; 
  bool vctr_is_found, chnk_is_found;
  uint32_t vctr_where_found, chnk_where_found;

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }

  status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found, 
      &chnk_where_found);
  cBYE(status);
  if ( chnk_is_found == false ) { go_BYE(-1); }
  if ( strcmp(rw, "read") == 0 ) { 
    *ptr_num = g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_readers;
  }
  else if ( strcmp(rw, "write") == 0 ) { 
    *ptr_num = g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_readers;
  }
  else { 
    go_BYE(-1);
  }
BYE:
  return status;
}

int
chnk_incr_num_readers(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx
    )
{
  int status = 0; 
  bool vctr_is_found, chnk_is_found;
  uint32_t vctr_where_found, chnk_where_found;

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }

  status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found, 
      &chnk_where_found);
  cBYE(status);
  if ( chnk_is_found == false ) { go_BYE(-1); }
  g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_readers++;
BYE:
  return status;
}
