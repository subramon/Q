#ifndef __Q_HTTPD_TYPES_H
#define __Q_HTTPD_TYPES_H
#include "q_macros.h"

typedef enum _q_req_type {
  Undefined, // --- & ---
  DoString, // Read & C 
  DoFile, // Read & C 
  Diagnostics, // Read &  C  AND Lua
  Halt, // Read &  C
  Ignore, // Read &  C
  Restart, // Read &  C
} Q_REQ_TYPE;

#define MAX_HEADERS_SIZE 2048-1
#define MAX_LEN_BODY     65536-1
#define MAX_LEN_API_NAME 32-1
#define MAX_LEN_ARGS     128-1
#endif
