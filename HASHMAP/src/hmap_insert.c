#include "hmap_common.h"
#include "hmap_insert.h"
int
hmap_insert(
    hmap_t *ptr_hmap, 
    void *key,
    uint16_t len,
    uint32_t hash
    )
{
  int status = 0;
  if ( key == NULL ) { return status; } // not a valid key 
  if ( hash == 0 ) { // not a valid hash 
    hash = murmurhash3(key, len, ptr_hmap->hashkey);
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
    void *this_key = bkts[probe_loc].key;
    uint16_t this_len  = bkts[probe_loc].len;
    uint16_t this_hash = bkts[probe_loc].hash;
    if ( this_key != NULL ) { // If there is a key in the bucket.
      if ( ( this_len == len ) && ( this_hash == hash ) && 
           ( memcmp(key, this_key, len) == 0 ) ) { 
        // TODO: Do the aggregation
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
