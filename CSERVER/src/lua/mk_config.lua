local cutils    = require 'libcutils'
local ffi       = require 'ffi'
local stringify = require 'Q/CSERVER/src/lua/stringify'

local function mk_config(C)
  assert(C)
  C = ffi.cast("config_t *", C)
  local config    = require 'Q/CSERVER/src/lua/config'
  assert(type(config) == "table")
  --=========================
  local port = assert(config.port)
  assert(type(port) == "number")
  assert(port > 1024)
  C[0].port = port
  --=========================
  local qc_flags = assert(config.qc_flags)
  assert(type(qc_flags) == "string")
  assert(#qc_flags > 0)
  -- assert(cutils.isdir(qc_flags))
  C[0].qc_flags = stringify(qc_flags)
  --=========================
end
return mk_config
