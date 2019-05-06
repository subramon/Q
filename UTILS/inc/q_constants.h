#ifndef __Q_CONSTANTS_H
#define __Q_CONSTANTS_H
// Commnting Q_CHUNK_SIZE as it is referenced from q_consts.lua
//#define Q_CHUNK_SIZE 65536
#define Q_MIN_CHUNK_SIZE_OPENMP 64
#define Q_MAX_LEN_INTERNAL_NAME  31
#define Q_MAX_LEN_DIR 127
#define Q_MAX_LEN_BASE_FILE 63
#define Q_MAX_LEN_FILE_NAME  Q_MAX_LEN_DIR+Q_MAX_LEN_BASE_FILE+1

#endif
