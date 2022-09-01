#include "q_incs.h"
#include "q_macros.h"
#include "qtypes.h"
#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
#include "rs_hmap_int_struct.h"
#include "rs_hmap_instantiate.h"

#include "mk_chnk_hmap.h" 

rs_hmap_t g_chnk_hmap;

int 
mk_chnk_hmap(
    void
    )
{
  int status;
  memset(&g_chnk_hmap, 0, sizeof(rs_hmap_t));
  rs_hmap_config_t HC1; memset(&HC1, 0, sizeof(rs_hmap_config_t));
  HC1.min_size = 32;
  HC1.max_size = 0;
  HC1.so_file = strdup("libhmap_CHNK.so"); 
  status = rs_hmap_instantiate(&g_chnk_hmap, &HC1); cBYE(status);

  rs_hmap_int_config_t *IC1 = g_chnk_hmap.int_config;
  status = IC1->bkt_chk_fn(g_chnk_hmap.bkts, g_chnk_hmap.size);
  cBYE(status);
BYE:
  return status;
}
