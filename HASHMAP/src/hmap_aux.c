#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
#include "rdtsc.h"
#include "hmap_aux.h"

uint32_t
mk_hmap_key(
    void
    )
{
  uint64_t r1 = random() ^ RDTSC();
  uint64_t r2 = random() ^ RDTSC();
  return (uint32_t)( r1 | ( r2 << 32 )  );
}
