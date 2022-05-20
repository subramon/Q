/*
 * hmap_del: remove the given key and return its value.
 * => If key was present, return its associated value; otherwise NULL.
 */
#include "hmap_common.h"
#include "hmap_aux.h"
#include "hmap_resize.h"
#include "hmap_del.h"
int
hmap_del(
    hmap_t *H, 
    const void *key, 
    bool *ptr_is_found,
    dbg_t *ptr_dbg
    )
{
  int status = 0;

  if ( key == NULL ) { go_BYE(-1); } // not a valid key 
  if ( key == NULL ) { go_BYE(-1); } // not a valid key 
  uint16_t len_to_hash; char *str_to_hash = NULL; bool free_to_hash;
  status = H->key_hash(key, &str_to_hash, &len_to_hash, &free_to_hash); 
  register uint32_t hash = set_hash(str_to_hash, len_to_hash, 
      H, ptr_dbg);

  register uint32_t probe_loc = set_probe_loc(hash, H, ptr_dbg);
  register bkt_t *bkts = H->bkts;
  register uint32_t my_psl = 0;
  register uint32_t num_probes = 0;
  *ptr_is_found = false;

  register bkt_t *this_bkt;
  for ( ; ; ) {
    if ( num_probes >= H->size ) { go_BYE(-1); }
    this_bkt = bkts + probe_loc;
    // same probing logic as in lookup function.
    if ( ( this_bkt->key == NULL ) || ( my_psl > this_bkt->psl) ) { 
      // key does not exist 
      goto BYE;
    }

    if (( this_bkt->hash == hash ) && ( H->key_cmp(this_bkt->key, key) )) {
      *ptr_is_found = true;
      break;
    }
    my_psl++;
    /* Continue to the next bucket. */
    probe_loc++;
    if ( probe_loc == H->size ) { probe_loc = 0; }
    num_probes++;
  }
  if ( *ptr_is_found == false ) { go_BYE(-1); }

   // Free the bucket.
  H->key_free(this_bkt->key);
  H->val_free(this_bkt->val);
  H->nitems--;

  /*
   * The probe sequence must be preserved in the deletion case.
   * Use the backwards-shifting method to maintain low variance.
   */
  for ( ; ; ) {
    memset(this_bkt, 0, sizeof(bkt_t));
    bkt_t *next_bkt;

    probe_loc++;
    if ( probe_loc == H->size ) { probe_loc = 0; }
    next_bkt = bkts + probe_loc;
    /*
     * Stop if we reach an empty bucket or hit a key which
     * is in its base (original) location.
     */
    if ( ( next_bkt->key == NULL ) || ( next_bkt->psl == 0 ) ) { 
      break;
    }
    next_bkt->psl--;
    *this_bkt = *next_bkt;
    this_bkt = next_bkt;
  }

  /*
   * If the load factor is less than threshold, then shrink the hash table
   * However, don't go below minimum size
   */
  size_t threshold = LOW_WATER_MARK * H->size;
  if ( ( H->nitems > H->config.min_size ) && 
       ( H->nitems < threshold ) ) {
    size_t new_size = ((LOW_WATER_MARK+HIGH_WATER_MARK)/2.0)*H->nitems;
    if ( new_size < H->config.min_size ) { 
      new_size = H->config.min_size;
    }
    status = hmap_resize(H, new_size); cBYE(status); 
  }
BYE:
  return status;
}
