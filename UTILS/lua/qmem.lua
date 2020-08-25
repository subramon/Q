local ffi     = require 'ffi'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local qc      = require 'Q/UTILS/lua/qcore'
local stringify = require 'Q/UTILS/lua/stringify'
local add_trailing_slash = require 'Q/UTILS/lua/add_trailing_slash'

qc.q_cdef("UTILS/inc/qmem_struct.h")
qc.q_cdef("UTILS/inc/q_common.h")

local Q_CHUNK_SIZE         = 262144
local Q_INITIAL_NUM_CHUNKS = 262144
local Q_INITIAL_NUM_VECS   = 1024

local sz, n
local qmem = {}

sz = ffi.sizeof("qmem_struct_t")
local cdata = cmem.new(sz); cdata:zero()
local cst_cdata = ffi.cast("qmem_struct_t *", cdata:data())
--==================================
qmem.q_data_dir = assert(os.getenv("Q_DATA_DIR"))
qmem.q_data_dir = add_trailing_slash(qmem.q_data_dir)

cst_cdata[0].q_data_dir = stringify(qmem.q_data_dir)
cst_cdata[0].uqid_gen   = 0

qmem.chunk_size = Q_CHUNK_SIZE -- default value 
cst_cdata[0].chunk_size = qmem.chunk_size

cst_cdata[0].max_mem_KB = 1048576 -- default value 
qmem.max_mem_KB = 1048576 -- default value 

cst_cdata[0].now_mem_KB = 0       -- initial value 

--=====================================================

sz = ffi.sizeof("chunk_dir_t ")
local chunk_dir = cmem.new(sz); chunk_dir:zero()
local cst_chunk_dir = 
  ffi.cast("chunk_dir_t  *", chunk_dir:data())
cst_cdata[0].chunk_dir = cst_chunk_dir

cst_chunk_dir[0].n = 0
cst_chunk_dir[0].sz = Q_INITIAL_NUM_CHUNKS

sz = Q_INITIAL_NUM_CHUNKS * ffi.sizeof("CHUNK_REC_TYPE ") 
local chunks = cmem.new(sz); chunks:zero()
local cst_chunks = 
  ffi.cast("CHUNK_REC_TYPE  *", chunks:data())
cst_chunk_dir[0].chunks = cst_chunks
--=====================================================

sz = ffi.sizeof("whole_vec_dir_t ")
local whole_vec_dir = cmem.new(sz); whole_vec_dir:zero()
local cst_whole_vec_dir = 
  ffi.cast("whole_vec_dir_t  *", whole_vec_dir:data())
cst_cdata[0].whole_vec_dir = cst_whole_vec_dir

cst_whole_vec_dir[0].n = 0
cst_whole_vec_dir[0].sz = Q_INITIAL_NUM_VECS 

sz = Q_INITIAL_NUM_VECS * ffi.sizeof("WHOLE_VEC_REC_TYPE ") 
local whole_vecs = assert(cmem.new(sz)); whole_vecs:zero()
local cst_whole_vecs = 
  ffi.cast("WHOLE_VEC_REC_TYPE  *", whole_vecs:data())
cst_whole_vec_dir[0].whole_vecs = cst_whole_vecs
--=====================================================
--===========================
local function init(T)
  -- == Check new values
  if ( T.q_data_dir ) then 
    assert(type(T.q_data_dir) == "string")
    assert(cutils.isdir(T.q_data_dir))
    qmem.q_data_dir = T.q_data_dir  -- hand to Lua 
    -- now hand  to C
    if ( cst_cdata[0].q_data_dir ~= ffi.NULL ) then 
      ffi.C.free(cst_cdata[0].q_data_dir)
      cst_cdata[0].q_data_dir = ffi.NULL
    end
    cst_cdata[0].q_data_dir = stringify(T.q_data_dir)
  end 

  if ( T.chunk_size ) then 
    error("not allowed to change chunk_size; at least, not now")
    --[[
    assert(type(T.chunk_size) == "number")
    assert(T.chunk_size > 0)
    qmem.chunk_size = T.chunk_size -- hand to Lua 
    cst_cdata[0].chunk_size = T.chunk_size 
    --]]
  end 
  
  if ( T.max_mem_KB)  then 
    assert(type(T.max_mem_KB) == "number")
    assert(T.max_mem_KB > 0)
    assert(T.max_mem_KB > tonumber(cst_cdata[0].max_mem_KB))
    cst_cdata[0].max_mem_KB = T.max_mem_KB
    qmem.max_mem_KB = max_mem_KB
  end

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
  if ( cst_cdata[0].q_data_dir ~= ffi.NULL ) then 
    ffi.C.free(cst_cdata[0].q_data_dir)
  end
  chunks:delete()
  chunk_dir:delete()
  whole_vecs:delete()
  whole_vec_dir:delete()
  cdata:delete()
end 
--===================

qmem.cdata = cdata -- not to be modified by Lua, just pass through to C
qmem.init  = init 
qmem.get   = get  
qmem._release = release -- use with GREAT CARE !!!!!
return qmem
