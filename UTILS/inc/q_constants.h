#ifndef __Q_CONSTANTS_H
#define __Q_CONSTANTS_H
#define Q_MAX_LEN_VEC_NAME 63
#define Q_MIN_CHUNK_SIZE_OPENMP 64
#define Q_MAX_LEN_INTERNAL_NAME  31
#define Q_MAX_LEN_QTYPE_NAME    3
#define Q_MAX_LEN_DIR 127
#define Q_MAX_LEN_BASE_FILE 63
#define Q_MAX_LEN_FILE_NAME  Q_MAX_LEN_DIR+Q_MAX_LEN_BASE_FILE+1

#define Q_CORE_VEC_ALIGNMENT  256 
#define Q_CMEM_ALIGNMENT  256 
#define Q_SCLR_ALIGNMENT  0
#define Q_VEC_ALIGNMENT   16

//- for spooky hash 
#define SC_NUMVARS 12 
#define SC_BLOCKSIZE (8 * SC_NUMVARS)
#define SC_BUFSIZE (2 * SC_BLOCKSIZE)
//-----------------
// for vector globals
#define Q_INITIAL_SZ_CHUNK_DIR 1024
#endif
