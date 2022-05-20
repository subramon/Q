// lookup an value given the key.
#include "hmap_common.h"
#include "hmap_aux.h"
#include "hmap_get.h"
#define REGISTER 

int
hmap_get(
    hmap_t *H, 
    const void * const key, 
    void **ptr_val,
    bool *ptr_is_found,
    uint32_t *ptr_where_found,
    dbg_t *ptr_dbg
    )
{
  int status = 0;

  REGISTER uint32_t num_probes = 0;
  if ( key == NULL ) { go_BYE(-1); } // not a valid key 

  uint16_t len_to_hash; char *str_to_hash = NULL; bool free_to_hash;
  status = H->key_hash(key, &str_to_hash, &len_to_hash, &free_to_hash); 
  REGISTER uint32_t hash = set_hash(str_to_hash, len_to_hash, 
      H, ptr_dbg);
  if ( free_to_hash ) { free(str_to_hash); str_to_hash = NULL; }

  REGISTER uint32_t probe_loc = set_probe_loc(hash, H, ptr_dbg);
  REGISTER bkt_t *bkts = H->bkts;
  REGISTER uint32_t my_psl = 0;
  *ptr_is_found = false;
  *ptr_where_found = UINT_MAX; // bad value

  // Lookup is a linear probe.
  for ( ; ; ) { 
    if ( num_probes >= H->size ) { go_BYE(-1); }
    REGISTER bkt_t *this_bkt = bkts + probe_loc;

    if ( this_bkt->hash != hash ) { goto keep_searching; }  // mismatch 
    if ( !H->key_cmp(this_bkt->key, key) ) { // mismatch 
      goto keep_searching;   
    }
    if ( ptr_val != NULL ) { 
      *ptr_val = H->val_copy(this_bkt->val); 
      if ( ptr_val == NULL ) {go_BYE(-1); }
    }
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
    if ( ( this_bkt->key == NULL ) || ( my_psl > this_bkt->psl ) ) {
      break;
    }
    my_psl++;
    /* Continue to the next bucket. */
    probe_loc++;
    if ( probe_loc == H->size ) { probe_loc = 0; }
    num_probes++;
  }
BYE:
  if ( ptr_dbg != NULL ) { 
    ptr_dbg->num_probes += num_probes;
  }
  return status;
}
