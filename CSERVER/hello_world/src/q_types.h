#ifndef __Q_HTTPD_TYPES_H
#define __Q_HTTPD_TYPES_H
#include "q_incs.h"

typedef enum _q_req_type {
  Undefined, // --- & ---
  DoString, // Read & C 
  DoFile, // Read & C 
  Diagnostics, // Read &  C  AND Lua
  DumpLog, // Read &  C
  GetConfig, // Read &  Lua
  GetNumFeatures, // Read &  Lua
  Halt, // Read &  C
  HealthCheck, // Read &  C
  Ignore, // Read &  C
  LoadModels, // Write &  Lua TODO 
  MakeFeatureVector, // Read &  Lua
  MdlMeta, // Read & Lua 
  PostProcPreds, // Read &  C
  Restart, // Read &  C
  ZeroCounters // Write &  C
} Q_REQ_TYPE;

#endif
