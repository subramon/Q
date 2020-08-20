local tests = {}
tests.t1 = function()
  local qmem = require 'qmem'
  local T = qmem.get()
  assert(type(T) == "table")
  local V = {}
  for k, v in pairs(T) do V.k = v end 
  V.chunk_size = T.chunk_size + 1 
  V.max_mem_KB = T.max_mem_KB + 1 
  V.q_data_dir = T.q_data_dir
  assert(qmem.init(V))
  W = qmem.get()
  assert(W.chunk_size == T.chunk_size + 1 )
  assert(W.max_mem_KB == T.max_mem_KB + 1 )
  qmem._release()
  print("Test t1 succeeded")
end
-- tests.t1()
return tests
