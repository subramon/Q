#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <inttypes.h>

#include "fasthash.h"
// #include "m_fasthash.h"
static  uint64_t
RDTSC(
    void
    )
{
  unsigned int lo, hi;
  asm volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
}

int
main()
{
  char **keys = NULL;
  int *lens = NULL;
  uint64_t *hashes = NULL;
  uint64_t *chk_hashes = NULL;
  int nkeys = 1048576;
  uint64_t seed = 123456789;

  srandom(seed);
  lens = malloc(nkeys * sizeof(int));
  keys = malloc(nkeys * sizeof(char *));
  hashes = malloc(nkeys * sizeof(uint64_t));
  chk_hashes = malloc(nkeys * sizeof(uint64_t));
  for ( int i = 0; i < nkeys; i++ ) { 
    keys[i] = malloc(32);
    sprintf(keys[i], "%ld", random());
    lens[i] = strlen(keys[i]);
    chk_hashes[i] = fasthash64(keys[i], lens[i], seed);
  }
  uint64_t t1 = RDTSC();
  for ( int i = 0; i < nkeys; i++ ) { 
    chk_hashes[i] = fasthash64(keys[i], lens[i], seed);
  }
  uint64_t t2 = RDTSC();
  // m_fasthash((uint8_t **)keys, lens, nkeys, seed, hashes);
  uint64_t t3 = RDTSC();
  /*
  for ( int i = 0; i < nkeys; i++) { 
    fprintf(stdout, "%s,%" PRIu64", %" PRIu64" \n", 
        keys[i], hashes[i], chk_hashes[i]);
  }
  */
  fprintf(stdout,"%lf\t%lf\n", (t2-t1)/1000.0, (t3-t2)/1000.0);
// ISPC is slower :-) --> 21971.974, 27612.678
}
