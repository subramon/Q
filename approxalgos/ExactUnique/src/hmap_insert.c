#include "hmap_common.h"
#include "hmap_insert.h"
int
hmap_insert(
    hmap_t *ptr_hmap, 
    uint64_t key,
    uint32_t hash
    )
{
  int status = 0;
  if ( key == 0 ) { // key of 0 treated as special case
    ptr_hmap->has_zero = true;
    return status;
  }
  if ( hash == 0 ) { 
    hash = murmurhash3(&key, sizeof(uint64_t), ptr_hmap->hashkey);
  }
  register uint32_t probe_loc; // location where we probe
  register uint32_t size = ptr_hmap->size;
  uint64_t divinfo = ptr_hmap->divinfo;

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
  memset(&entry, '\0', sizeof(bkt_t));
  entry.key = key;
  register uint32_t num_probes = 0;
  //-----------
  register bkt_t *bkts  = ptr_hmap->bkts;
  probe_loc = fast_rem32(hash, size, divinfo);
  if ( probe_loc >= size ) { go_BYE(-1); }
  for ( ; ; ) {
    if ( num_probes >= size ) { go_BYE(-1); }
    uint64_t this_key = bkts[probe_loc].key;
    if ( this_key != 0 ) { // If there is a key in the bucket.
      if ( this_key == key ) { 
        // nothing to do 
        break;
      }
      //-----------------------
      // We found a "rich" bucket.  Capture its location.
      if ( entry.psl > bkts[probe_loc].psl ) {
        bkt_t tmp;
        tmp = entry;
        entry = bkts[probe_loc];
        bkts[probe_loc] = tmp;
      }
      entry.psl++;
      /* Continue to the next bucket. */
      num_probes++;
      probe_loc++;
      if ( probe_loc == size ) { probe_loc = 0; }
    }
    else {
      bkts[probe_loc] = entry;
      ptr_hmap->nitems++;
      break;
    }
  }
BYE:
  return status;
}
