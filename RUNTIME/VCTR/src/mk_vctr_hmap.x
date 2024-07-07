#include "q_incs.h"
#include "q_macros.h"
#include "qtypes.h"
#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
#include "rs_hmap_int_struct.h"
#include "rs_hmap_instantiate.h"
#include "mk_vctr_hmap.h" 

void *
mk_vctr_hmap(
    void
    )
{
  int status;
  rs_hmap_t *vctr_hmap = NULL;

  rs_hmap_config_t HC1; memset(&HC1, 0, sizeof(rs_hmap_config_t));
  HC1.min_size = 32;
  HC1.max_size = 0;
  HC1.so_file = strdup("libhmap_VCTR.so"); 
  status = rs_hmap_instantiate(vctr_hmap, &HC1); cBYE(status);

  rs_hmap_int_config_t *IC1 = vctr_hmap->int_config;
  status = IC1->bkt_chk_fn(vctr_hmap->bkts, vctr_hmap->size);
  cBYE(status);
BYE:
  if ( status != 0 ) { return NULL; } else { return vctr_hmap; }
}
