#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
#include "rs_hmap_aux.h"
#include "rsx_set_hash.h"
#include "rs_hmap_insert.h"

int
rs_hmap_insert(
    rs_hmap_t *ptr_hmap, 
    const void * const *in_ptr_key, 
    const void * const *in_ptr_val
    )
{
  int status = 0;
  const rs_hmap_key_t * const ptr_key = (const rs_hmap_key_t * const )in_ptr_key;
  const rs_hmap_val_t * const ptr_val = (const rs_hmap_val_t * const )in_ptr_val;
  register uint32_t hash = rsx_set_hash(ptr_key, ptr_hmap);
  register uint32_t probe_loc = set_probe_loc(hash, ptr_hmap);
  register val_update_fn_t val_update = ptr_hmap->val_update;
  register key_cmp_fn_t key_cmp = ptr_hmap->key_cmp;

  /*
   * From the paper: "when inserting, if a record probes a location
   * that is already occupied, the record that has traveled longer
   * in its probe sequence keeps the location, and the other one
   * continues on its probe sequence" (page 12).
   *
   * Basically: if the probe sequence length (PSL) of the element
   * being inserted is greater than PSL of the element in the bucket,
   * then swap them and continue.
   */
  // set up the bucket entry 
  bkt_t entry; 
  rs_hmap_key_t key = *ptr_key;
  rs_hmap_val_t val = *ptr_val;
  entry.key  = *ptr_key;
  entry.val  = *ptr_val;
  entry.psl  = 0;
  bool key_copied = false; // means we have not copied the key or val
  register uint32_t num_probes = 0;
  //-----------
  register bkt_t *bkts  = ptr_hmap->bkts;
  register bool *bkt_full  = ptr_hmap->bkt_full;
  for ( ; ; ) {
    if ( num_probes >= ptr_hmap->size ) { go_BYE(-1); }
    rs_hmap_key_t this_key       = bkts[probe_loc].key;
    if ( bkt_full[probe_loc] ) { // If there is a key in the bucket.
      // check if key matches incoming one 
      if ( key_cmp(&this_key, &key) ) { 
        // update the existing value with the new value in *ptr_val
        status = val_update(&(bkts[probe_loc].val), &val);  
        cBYE(status);
        break;
      }
      // control comes here => bucket is full but not with incoming key
      //-----------------------
      // We found a "rich" bucket.  Capture its location.
      if ( entry.psl > bkts[probe_loc].psl ) {
        // swap 
        bkt_t tmp = entry;
        entry = bkts[probe_loc];
        bkts[probe_loc] = tmp;
        //--------------
        key  = entry.key;
        val  = entry.val;
      }
      entry.psl++;
      /* Continue to the next bucket. */
      num_probes++;
      probe_loc++;
      if ( probe_loc == ptr_hmap->size ) { probe_loc = 0; }
    }
    else { // spot is empty, grab it 
      if ( key_copied ) { go_BYE(-1); } // this cannot happen 
      bkts[probe_loc]     = entry;
      bkt_full[probe_loc] = true; 
      ptr_hmap->nitems++; // one more item in hash table 
      //--------------
      break;
    }
  }
BYE:
  return status;
}
