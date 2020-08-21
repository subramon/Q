local ffi    = require 'ffi'
local cmem   = require 'libcmem'
local cutils = require 'libcutils'
local add_trailing_bslash = require 'Q/UTILS/lua/add_trailing_bslash'
local stringify = require 'Q/UTILS/lua/stringify'
local qc     = require 'Q/UTILS/lua/qcore'
local qc     = require 'Q/UTILS/lua/qcore'

local sz, n

qc.q_cdef("UTILS/inc/qmem_struct.h")
pcall(ffi.cdef, "extern void *malloc(size_t);")
pcall(ffi.cdef, "extern void free (void *);")

local qmem = {}

local sz = ffi.sizeof("qmem_struct_t")
local cdata = assert(ffi.C.malloc(sz))
ffi.fill(cdata, 0)
cst_cdata = ffi.cast("qmem_struct_t *", cdata)

--=====================================================
sz = ffi.sizeof("chunk_dir_t ")
local chunk_dir = assert(ffi.C.malloc(sz))
ffi.fill(chunk_dir, 0)
cst_chunk_dir = ffi.cast("chunk_dir_t  *", chunk_dir)
cst_cdata[0].chunk_dir = cst_chunk_dir

n = 262144 -- default value 
sz = n * ffi.sizeof("CHUNK_REC_TYPE ") 
local chunks = assert(ffi.C.malloc(sz))
ffi.fill(chunks, 0)
cst_chunks = ffi.cast("CHUNK_REC_TYPE  *", chunks)
cst_cdata[0].chunk_dir[0].chunks = cst_chunks
cst_cdata[0].chunk_dir[0].sz = 262144
cst_cdata[0].chunk_dir[0].n  = 0
--=====================================================
sz = ffi.sizeof("whole_vec_dir_t ")
local whole_vec_dir = assert(ffi.C.malloc(sz))
ffi.fill(whole_vec_dir, 0)
cst_whole_vec_dir = ffi.cast("whole_vec_dir_t  *", whole_vec_dir)
cst_cdata[0].whole_vec_dir = cst_whole_vec_dir

n = 1024 -- default value 
sz = n * ffi.sizeof("WHOLE_VEC_REC_TYPE ") 
local whole_vecs = assert(ffi.C.malloc(sz))
ffi.fill(whole_vecs, 0)
cst_whole_vecs = ffi.cast("WHOLE_VEC_REC_TYPE  *", whole_vecs)
cst_cdata[0].whole_vec_dir[0].whole_vecs = cst_whole_vecs
cst_cdata[0].whole_vec_dir[0].sz = n
cst_cdata[0].whole_vec_dir[0].n  = 0
--=====================================================
--===========================
-- TODO  cVector qcfg.Q_DATA_DIR for data_dir
-- TODO Use cVector qcfg.chunk_size for chunk_size

qmem.q_data_dir = os.getenv("Q_DATA_DIR")
qmem.chunk_size = 65536 -- default value 
qmem.max_mem_KB = 1048576 -- default value 
local function init(T)
  -- == Check new values
  assert(type(T.q_data_dir) == "string")
  assert(cutils.isdir(T.q_data_dir))

  assert(type(T.chunk_size) == "number")
  assert(T.chunk_size > 0)
  
  assert(type(T.max_mem_KB) == "number")
  assert(T.max_mem_KB > 0)
  -- == Set new values
  -- Following needed by C 
  cst_cdata[0].chunk_size = T.chunk_size 
  cst_cdata[0].max_mem_KB = T.max_mem_KB
  -- Following needed by Lua and C
  qmem.chunk_size = T.chunk_size 
  qmem.q_data_dir = T.q_data_dir 
  qmem.max_mem_KB = T.max_mem_KB 
  return true
end
local function get()
  local T = {}
  T.q_data_dir = qmem.q_data_dir
  T.chunk_size = qmem.chunk_size 
  T.max_mem_KB = qmem.max_mem_KB 
  return T
end
local function release()
  if ( cdata  ) then ffi.C.free(cdata) end 
  if ( chunks ) then ffi.C.free(chunks) end 
  if ( chunk_dir ) then ffi.C.free(chunk_dir) end 
end 
init(get()) -- Do first call 
--===================

qmem._cdata = cst_cdata -- not to be modified by Lua, just pass through to C
qmem.init  = init 
qmem.get   = get  
qmem._release = release -- use with GREAT CARE !!!!!
return qmem
