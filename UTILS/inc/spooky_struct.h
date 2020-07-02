#ifndef __SPOOKY_STRUCT_H
#define __SPOOKY_STRUCT_H
#define SC_NUMVARS 12 // keep in sync with NUMVARS below
#define SC_BLOCKSIZE (8 * SC_NUMVARS)
#define SC_BUFSIZE (2 * SC_BLOCKSIZE)
typedef struct spooky_state {
  uint64_t m_data[2*12]; // was [2 * SC_NUMVARS]; sync with NUMVARS above
  uint64_t m_state[12]; // was [SC_NUMVARS]; sync with NUMVARS above
  size_t m_length;
  unsigned char m_remainder;
  uint64_t q_seed;  // only for Q
  int q_stride;  //  only for Q
} SPOOKY_STATE;

#endif 

