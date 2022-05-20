/*
 * hmap_del: remove the given key and return its value.
 * => If key was present, return its associated value
 */
#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
#include "rs_hmap_aux.h"
#include "rs_hmap_resize.h"
#include "rs_hmap_del.h"
int
rs_hmap_del(
    rs_hmap_t *ptr_hmap, 
    const void * const in_ptr_key, 
    void * in_ptr_val, // if NULL => we do not care for value
    bool *ptr_is_found
    )
{
  int status = 0;

  if ( ptr_hmap == NULL ) { go_BYE(-1); } 
  if ( in_ptr_key == NULL ) { go_BYE(-1); } 
  const rs_hmap_key_t * const ptr_key = (const rs_hmap_key_t * const )in_ptr_key;
  rs_hmap_val_t * ptr_val = (rs_hmap_val_t * )in_ptr_val;

  register uint32_t hash = set_hash(ptr_key, ptr_hmap);
  register uint32_t probe_loc = set_probe_loc(hash, ptr_hmap);
  register bkt_t *bkts = ptr_hmap->bkts;
  register bool *bkt_full = ptr_hmap->bkt_full;
  register uint32_t my_psl = 0;
  register uint32_t num_probes = 0;
  rs_hmap_int_config_t *C = (rs_hmap_int_config_t *)ptr_hmap->int_config;
  register key_cmp_fn_t key_cmp_fn = C->key_cmp_fn;

  // Start by assuming that key is not found. 
  *ptr_is_found = false;
  if ( in_ptr_val != NULL ) { 
    memset(in_ptr_val, 0, sizeof(rs_hmap_val_t));
  }

  for ( ; ; ) {
    if ( num_probes >= ptr_hmap->size ) { go_BYE(-1); }
    // same probing logic as in lookup function.
    uint16_t this_psl = bkts[probe_loc].psl; 
    if ( bkt_full[probe_loc] == false ) { // bucket is empty
      goto BYE;
    }
    if ( my_psl > this_psl) { // key does not exist 
      goto BYE;
    }
    // check if key matches incoming one 
    if ( key_cmp_fn(&(bkts[probe_loc].key), ptr_key) ) { 
      *ptr_is_found = true;
      if ( ptr_val != NULL ) {  // return value of deleted key
        *ptr_val = bkts[probe_loc].val; 
      }
      break;
    }
    my_psl++;
    /* Continue to the next bucket. */
    probe_loc++;
    if ( probe_loc == ptr_hmap->size ) { probe_loc = 0; }
    num_probes++;
  }

  // if key does not exist, we should have returned by now 
  if ( *ptr_is_found == false ) { go_BYE(-1); }

  ptr_hmap->nitems--;
  // We found the key at probe_loc

  /*
   * The probe sequence must be preserved in the deletion case.
   * Use the backwards-shifting method to maintain low variance.
   */
  bkt_t *this_bkt  = &(bkts[probe_loc]);
  uint32_t prev_probe_loc = probe_loc; 
  for ( ; ; ) {
    // mark this bucket as empty
    memset(&(bkts[probe_loc]), 0, sizeof(bkt_t));
    bkt_full[probe_loc] = false; 

    probe_loc++;
    if ( probe_loc == ptr_hmap->size ) { probe_loc = 0; }
    bkt_t *next_bkt = bkts + probe_loc;
    /*
     * Stop if we reach an empty bucket or hit a key which
     * is in its base (original) location.
     */
    if ( ( bkt_full[probe_loc] == false ) || ( next_bkt->psl == 0 ) ) { 
      break;
    }
    next_bkt->psl--;
    *this_bkt = *next_bkt;
    this_bkt = next_bkt;
    bkt_full[prev_probe_loc] = bkt_full[probe_loc];
    prev_probe_loc = probe_loc; 
  }

  /*
   * If the load factor is less than threshold, then shrink by
   * halving the size, but not more than the minimum size.
   */
  size_t threshold = LOW_WATER_MARK * (double)ptr_hmap->size;
  if ( ( ptr_hmap->nitems > ptr_hmap->config.min_size ) && 
       ( ptr_hmap->nitems < threshold ) ) {
    size_t new_size = (double)ptr_hmap->nitems / IDEAL_WATER_MARK;
    if ( new_size < ptr_hmap->config.min_size ) { 
      new_size = ptr_hmap->config.min_size;
    }
    status = rs_hmap_resize(ptr_hmap, new_size); cBYE(status); 
  }
BYE:
  return status;
}
