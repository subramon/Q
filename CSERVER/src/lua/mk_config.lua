local cutils    = require 'libcutils'
local ffi       = require 'ffi'
local stringify = require 'Q/CSERVER/src/lua/stringify'

local function mk_config(S)
  assert(S)
  S = ffi.cast("q_server_t *", S)
  local config    = require 'Q/CSERVER/src/lua/config'
  assert(type(config) == "table")
  --=========================
  local port = assert(config.port)
  assert(type(port) == "number")
  assert(port > 1024)
  S[0].port = port
  --=========================
  local sz_body = assert(config.sz_body)
  assert(type(sz_body) == "number")
  assert(port > 1024)
  S[0].sz_body = sz_body
  --=========================
  local sz_rslt = assert(config.sz_rslt)
  assert(type(sz_rslt) == "number")
  assert(port > 1024)
  S[0].sz_rslt = sz_rslt
  --=========================
  local chunk_size = assert(config.chunk_size)
  assert(type(chunk_size) == "number")
  assert(chunk_size >= 64)
  assert( math.floor(chunk_size/64) == math.ceil(chunk_size/64) )
  S[0].chunk_size = chunk_size
  --=========================
  local qc_flags = assert(config.qc_flags)
  assert(type(qc_flags) == "string")
  assert(#qc_flags > 0)
  S[0].qc_flags = stringify(qc_flags)
  --=========================
  local q_data_dir = assert(config.q_data_dir)
  assert(type(q_data_dir) == "string")
  assert(#q_data_dir > 0)
  assert(cutils.isdir(q_data_dir))
  S[0].q_data_dir = stringify(q_data_dir)
  --=========================
  local q_root = assert(config.q_root)
  assert(type(q_root) == "string")
  assert(#q_root > 0)
  assert(cutils.isdir(q_root))
  S[0].q_root = stringify(q_root)
  --=========================
  local q_src_root = assert(config.q_src_root)
  assert(type(q_src_root) == "string")
  assert(#q_src_root > 0)
  assert(cutils.isdir(q_src_root))
  S[0].q_src_root = stringify(q_src_root)
  --=========================
end
return mk_config
