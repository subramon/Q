#ifndef SPOOKY_STRUCT_H
#define SPOOKY_STRUCT_H
typedef struct spooky_state {
  uint64_t m_data[2 * 12];
  uint64_t m_state[12];
  size_t m_length;
  unsigned char m_remainder;
  uint64_t q_seed;  // only for Q
  int q_stride;  //  only for Q
} SPOOKY_STATE;

#endif SPOOKY_STRUCT_H
