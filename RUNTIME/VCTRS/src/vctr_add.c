#include "q_incs.h"
#include "qtypes.h"
#include "vctr_new_uqid.h"
#include "vctr_add.h"

#include "rs_hmap_common.h"
#include "rs_hmap_int_types.h"
#include "rs_hmap_struct.h"
#include "rs_hmap_get.h"

extern rs_hmap_t g_vctr_hmap;

int
vctr_add1(
    qtype_t qtype,
    uint32_t *ptr_uqid
    )
{
  int status = 0;
  if ( ( qtype == Q0 ) || ( qtype >= NUM_QTYPES ) ) { go_BYE(-1); }
  *ptr_uqid = vctr_new_uqid();
  printf("uqid = %lu\n", *ptr_uqid);
  rs_hmap_key_t key = *ptr_uqid; 
  rs_hmap_val_t val = { .qtype = qtype } ;
  status = g_vctr_hmap.put(&g_vctr_hmap, &key, &val); cBYE(status);
BYE:
  return status;
}
