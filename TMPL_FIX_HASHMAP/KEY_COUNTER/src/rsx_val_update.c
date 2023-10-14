#include <stdio.h>
#include "rsx_types.h"
#include "rsx_val_update.h"
/*-------------------------------------------------------*/
#define WHEREAMI { fprintf(stderr, "Line %3d of File %s \n", __LINE__, __FILE__);  }
#define go_BYE(x) { WHEREAMI; status = x ; goto BYE; }
/*-------------------------------------------------------*/
//START_FUNC_DECL
int 
rsx_val_update(
    void *in_ptr_v1,
    const void * const in_ptr_v2
    )
//STOP_FUNC_DECL
{
  int status = 0;
  ${tmpl}_rs_hmap_val_t *ptr_v1 = (${tmpl}_rs_hmap_val_t * )in_ptr_v1;
  const ${tmpl}_rs_hmap_val_t *ptr_v2 = (const ${tmpl}_rs_hmap_val_t *const )in_ptr_v2;
  if ( ptr_v1->guid == 0 ) { go_BYE(-1); }
  if ( ptr_v1->count == 0 ) { go_BYE(-1); } 
  ptr_v1->count += ptr_v2->count;
BYE:
  return status;
}
