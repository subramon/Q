#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
#include "aux.h"
#include "_rs_hmap_set_fn_ptrs.h"
#include "_rs_hmap_instantiate.h"
int 
${tmpl}_rs_hmap_instantiate(
    ${tmpl}_rs_hmap_t *H, 
    const rs_hmap_config_t * const HC
    )
{
  int status = 0;
  H->start_check_val = 123456789;
  //----------------------------------------
  if ( HC->min_size == 0 ) { 
    H->config.min_size = HASH_MIN_SIZE;
  }
  else {
    H->config.min_size = HC->min_size;
  }
  //----------------------------------------
  if ( HC->max_size != 0 ) { 
    H->config.max_size = HC->max_size;
  }
  //----------------------------------------
  if ( HC->low_water_mark == 0 ) { 
    H->config.low_water_mark = LOW_WATER_MARK;
  }
  if ( ( H->config.low_water_mark <= 0 ) || 
       ( H->config.low_water_mark >= 1 ) ) {
    go_BYE(-1);
  }
  //----------------------------------------
  if ( HC->high_water_mark == 0 ) { 
    H->config.high_water_mark = HIGH_WATER_MARK;
  }
  if ( ( H->config.high_water_mark <= 0 ) || 
       ( H->config.high_water_mark >= 1 ) ) {
    go_BYE(-1);
  }
  //----------------------------------------
  if ( H->config.low_water_mark > 
       H->config.high_water_mark ) {
    go_BYE(-1);
  }
  //----------------------------------------

  // get smallest prime bigger than min size
  H->size = prime_geq(H->config.min_size);
  void *x;
  size_t w = sizeof(${tmpl}_rs_hmap_bkt_t);
  size_t sz = w * H->size;
  status = posix_memalign(&x, 16, sz); cBYE(status);
  memset(x, 0, sz);
  H->bkts = x;
  // H->bkts = calloc(H->size, sizeof(${tmpl}_rs_hmap_bkt_t)); 
  // return_if_malloc_failed(H->bkts);

  H->bkt_full = calloc(H->size, sizeof(bool)); 
  return_if_malloc_failed(H->bkt_full);

  H->divinfo = fast_div32_init(H->size);
  H->hashkey = mk_hmap_key();

  if ( ( HC->so_file == NULL ) || ( *HC->so_file == '\0' ) ) { go_BYE(-1); }
  H->config.so_file = strdup(HC->so_file);
  status = rs_hmap_set_fn_ptrs(H); cBYE(status);
BYE:
  return status;
}
