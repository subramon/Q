
#define chk_chunk_idx(x) { \
  if ( ( x <= 0 ) || ( (uint32_t)x >= ptr_S->chunk_dir->sz) ) { go_BYE(-1); } \
}

#define INITIAL_NUM_CHUNKS_PER_VECTOR 32
#define NUM_HEX_DIGITS_IN_UINT64      31 
