#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
#include "rdtsc.h"
#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
#include "rs_hmap_aux.h"
#include "fasthash.h"

uint32_t
mk_hmap_key(
    void
    )
{
  uint64_t r1 = random() ^ RDTSC();
  uint64_t r2 = random() ^ RDTSC();
  return (uint32_t)( r1 | ( r2 << 32 )  );
}
//----------------------------------------------
uint32_t
set_probe_loc(
    uint32_t hash,
    rs_hmap_t *ptr_hmap
    )
{
  uint32_t probe_loc;
  register uint32_t size = ptr_hmap->size;
  uint64_t divinfo = ptr_hmap->divinfo;
  probe_loc = fast_rem32(hash, size, divinfo);
  return probe_loc;
}

uint32_t 
prime_geq(
    uint32_t n
    )
{
  if ( n <= 1 ) { return 1; }
  // start with odd number >= n
  uint32_t m;
  if ( n % 0x1 == 1 ) { m = n; } else { m = n + 1 ; }
  for ( ; ; m = m + 2 ) { 
    bool is_prime = true;
    for ( uint32_t k = 3;  k <= sqrt(m); k = k + 2 ) { 
      if ( ( m % k ) == 0 ) { 
        is_prime = false; 
        break;
      }
    }
    if ( is_prime ) { 
      return m;
    }
  }
}
