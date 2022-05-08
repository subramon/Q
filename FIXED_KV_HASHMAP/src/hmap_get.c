// lookup an value given the key.
#include "hmap_common.h"
#include "hmap_struct.h" 
#include "hmap_aux.h"
#include "hmap_get.h"

int
hmap_get(
    hmap_t *ptr_hmap, 
    const void * const in_ptr_key, 
    void *in_ptr_val,
    bool *ptr_is_found,
    uint32_t *ptr_where_found
    )
{
  int status = 0;

  if ( in_ptr_key == NULL ) { go_BYE(-1); } // not a valid key 
  const key_t * const ptr_key = (const key_t * const)in_ptr_key;
  hmap_val_t *ptr_val = (hmap_val_t *)in_ptr_val;
  key_cmp_fn_t key_cmp_fn = ptr_hmap->config.key_cmp_fn;
  
  register uint32_t hash = set_hash(ptr_key, ptr_hmap);
  register uint32_t probe_loc = set_probe_loc(hash, ptr_hmap);
  register bkt_t *bkts = ptr_hmap->bkts;
  register bool *bkt_full = ptr_hmap->bkt_full;
  register uint32_t my_psl = 0;
  register uint32_t num_probes = 0;
  *ptr_is_found = false;
  *ptr_where_found = UINT_MAX; // bad value

  // Lookup is a linear probe.
  for ( ; ; ) { 
    if ( num_probes >= ptr_hmap->size ) { go_BYE(-1); }
    register bkt_t *this_bkt = bkts + probe_loc;

    if ( !key_cmp_fn(&(this_bkt->key), ptr_key) ) { // mismatch 
      goto keep_searching;   
    }
    *ptr_val = this_bkt->val;
    *ptr_where_found = probe_loc;
    *ptr_is_found = true;
    break;
keep_searching:
    /*
     * Stop probing if we hit an empty bucket; also, if we hit a
     * bucket with PSL lower than the distance from the base location,
     * then it means that we found the "rich" bucket which should
     * have been captured, if the key was inserted -- see the central
     * point of the algorithm in the insertion function.
     */
    if ( ( bkt_full[probe_loc] == false ) || 
          ( my_psl > this_bkt->psl ) ) {
      break;
    }
    my_psl++;
    /* Continue to the next bucket. */
    probe_loc++;
    if ( probe_loc == ptr_hmap->size ) { probe_loc = 0; }
    num_probes++;
  }
BYE:
  return status;
}
