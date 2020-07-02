#ifndef __Q_CONSTANTS_H
#define __Q_CONSTANTS_H
#define Q_MAX_LEN_VEC_NAME 63
#define Q_MIN_CHUNK_SIZE_OPENMP 64
#define Q_MAX_LEN_INTERNAL_NAME  31
#define Q_MAX_LEN_QTYPE_NAME    3
#define Q_MAX_LEN_CAST_AS      63
#define Q_MAX_LEN_DIR 127
#define Q_MAX_LEN_BASE_FILE 63
#define Q_MAX_LEN_FILE_NAME  Q_MAX_LEN_DIR+Q_MAX_LEN_BASE_FILE+1

//-------- for fldtypes as enums
// CAUTION: Needs to be in sync with q_consts.lua
#define QI1 1 
#define QI2 2
#define QI4 3
#define QI8 4
#define QF4 5
#define QF8 6
#define QSC 7
#define QTM 8
#define QB1 9
#endif
