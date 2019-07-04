#ifndef __SPOOKY_HASH_STRUCT
#define __SPOOKY_HASH_STRUCT
#include <stdint.h>
#include <stddef.h>

#define SC_NUMVARS 12
#define SC_BLOCKSIZE (8 * SC_NUMVARS)
#define SC_BUFSIZE (2 * SC_BLOCKSIZE)

typedef struct spooky_state {
  uint64_t m_data[2 * SC_NUMVARS];
  uint64_t m_state[SC_NUMVARS];
  size_t m_length;
  unsigned char m_remainder;
  uint64_t q_seed;  // only for Q
  int q_stride;  //  only for Q
} SPOOKY_STATE;
#endif
