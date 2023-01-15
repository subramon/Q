#include "rs_hmap_struct.h"
#include "rs_hmap_instantiate.h"
#include "hw2_rs_hmap_instantiate.h"
void *
hw2_rs_hmap_instantiate(
    const rs_hmap_config_t * const HC
    )
{
  int status = 0;
  rs_hmap_t *H = NULL;

  H = malloc(1 * sizeof(rs_hmap_t));
  memset(H, 0, (1 * sizeof(rs_hmap_t)));

  status = rs_hmap_instantiate(H, HC); cBYE(status);
BYE:
  if ( status < 0 ) { return NULL; } else { return H; } 
}
