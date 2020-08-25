local ffi = require 'ffi'
local tests = {}
tests.t1 = function()
  local qmem = require 'Q/UTILS/lua/qmem'
  local T = qmem.get()
  assert(type(T) == "table")
  local V = {}
  for k, v in pairs(T) do V[k] = v end 
  V.chunk_size = T.chunk_size + 2
  V.max_mem_KB = T.max_mem_KB +  3
  V.q_data_dir = T.q_data_dir
  -- for k, v in pairs(V) do print(k, v) end 
  assert(qmem.init(V))
  W = qmem.get()
  print("-=====")
  for k, v in pairs(W) do print(k, v) end 
  print("-=====")
  local cdata = ffi.cast("qmem_struct_t *", qmem._cdata)
  -- print("q_data_dir = ", ffi.string(cdata[0].q_data_dir))
  assert(ffi.string(cdata[0].q_data_dir) == W.q_data_dir)
  assert(cdata[0].uqid_gen == 0)
  assert(cdata[0].now_mem_KB == 0)

  assert(cdata[0].max_mem_KB > 0)
  -- print(cdata[0].max_mem_KB )
  assert(cdata[0].max_mem_KB == W.max_mem_KB)

  assert(cdata[0].whole_vec_dir ~= ffi.NULL)
  assert(cdata[0].chunk_dir ~= ffi.NULL)

  local w = ffi.cast("whole_vec_dir_t *", cdata[0].whole_vec_dir)
  assert(w.n == 0)
  assert(w.sz == 1024)

  local c = ffi.cast("chunk_dir_t *", cdata[0].chunk_dir)
  assert(c.n == 0)
  assert(c.sz == 262144)

  print("chunk_size = ", cdata[0].chunk_size)
  assert(cdata[0].chunk_size == W.chunk_size)
  qmem._release()
  print("Test t1 succeeded")
end
tests.t1()
