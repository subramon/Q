require 'Q/UTILS/lua/strict'
local ffi = require 'ffi'
local tests = {}
tests.t1 = function()
  local qmem = require 'Q/UTILS/lua/qmem'
  assert(qmem.init())
  local T = qmem.get()
  assert(type(T) == "table")
  -- for k, v in pairs(T) do print(k, v) end 
  -- create some different values for qmem
  local V = {}
  V.max_mem_KB = T.max_mem_KB +  3
  V.q_data_dir = "/tmp/"
  assert(qmem.update(V))
  --===================================
  W = qmem.get()

  local cdata = assert(qmem.cdata())
  assert(type(cdata) == "CMEM")
  local cdata = ffi.cast("qmem_struct_t *", cdata:data())
  -- print("q_data_dir = ", ffi.string(cdata[0].q_data_dir))
  assert(ffi.string(cdata[0].q_data_dir) == W.q_data_dir)
  assert(tonumber(cdata[0].uqid_gen) == 0)
  assert(tonumber(cdata[0].now_mem_KB) == 0)

  assert(tonumber(cdata[0].max_mem_KB) > 0)
  assert(tonumber(cdata[0].max_mem_KB) == V.max_mem_KB)

  assert(cdata[0].chunk_dir ~= ffi.NULL)
  assert(cdata[0].whole_vec_dir ~= ffi.NULL)

  local w = ffi.cast("whole_vec_dir_t *", cdata[0].whole_vec_dir)
  assert(w.n == 0)
  assert(w.sz == 1024)

  local c = ffi.cast("chunk_dir_t *", cdata[0].chunk_dir)
  assert(c.n == 0)
  assert(c.sz == 262144)

  assert(tonumber(cdata[0].chunk_size) == T.chunk_size)
  qmem._release()
  print("Test t1 succeeded")
end
tests.t1()
os.exit()
