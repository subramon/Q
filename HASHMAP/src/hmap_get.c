// lookup an value given the key.
#include "hmap_common.h"
#include "hmap_aux.h"
#include "hmap_get.h"
int
hmap_get(
    hmap_t *ptr_hmap, 
    const void * const key, 
    size_t len,
    val_t *ptr_val,
    bool *ptr_is_found,
    dbg_t *ptr_dbg
    )
{
  int status = 0;

  if ( key == NULL ) { go_BYE(-1); } // not a valid key 
  if ( len == 0    ) { go_BYE(-1); } // not a valid key 

  register uint32_t hash = set_hash(key, len, ptr_hmap, ptr_dbg);
  register uint32_t probe_loc = set_probe_loc(hash, ptr_hmap, ptr_dbg);
  register bkt_t *bkts = ptr_hmap->bkts;
  register uint32_t my_psl = 0;
  register uint32_t num_probes = 0;
  *ptr_is_found = false;

  // Lookup is a linear probe.
  for ( ; ; ) { 
    if ( num_probes >= ptr_hmap->size ) { go_BYE(-1); }
    register bkt_t *this_bkt = bkts + probe_loc;

    if ( ( this_bkt->hash == hash ) && ( this_bkt->len == len ) &&
        ( memcmp(this_bkt->key, key, len) == 0) ) {
      *ptr_val = this_bkt->val; 
      *ptr_is_found = true;
    }
    /*
     * Stop probing if we hit an empty bucket; also, if we hit a
     * bucket with PSL lower than the distance from the base location,
     * then it means that we found the "rich" bucket which should
     * have been captured, if the key was inserted -- see the central
     * point of the algorithm in the insertion function.
     */
    if ( ( this_bkt->key == NULL ) || ( my_psl > this_bkt->psl ) ) {
      goto BYE;
    }
    my_psl++;

    /* Continue to the next bucket. */
    probe_loc++;
    if ( probe_loc == ptr_hmap->size ) { probe_loc = 0; }
    num_probes++;
  }
BYE:
  if ( ptr_dbg != NULL ) { 
    ptr_dbg->num_probes += num_probes;
  }
  return status;
}
