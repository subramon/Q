local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'

local tests = {}

tests.t1 = function()
  local N = 256 * 65536
  local vec1 = Q.rand({lb = 0, ub = 10, qtype = "F4", len = N}):eval()
  local w = Q.rand({lb = 0, ub = 1, qtype = "F4", len = N}):eval()
  local loop_count = 16
  local A = {}

  local start_time = qc.RDTSC()
  for i = 1, loop_count do
    A[i] = {}
    local temp = Q.vvmul(vec1, w)
    for j = i, loop_count do
      A[i][j] = Q.vvmul(vec1, temp):eval()
    end
  end
  print("Eval case time = ", qc.RDTSC()-start_time)
  --[[
  for i = 1, loop_count do
    for j = i, loop_count do
      print(type(A[i][j]), A[i][j])
    end
  end
  ]]
  print(A)
  print("SUCCESS")
end

tests.t2 = function()
  local N = 256 * 65536
  local vec1 = Q.rand({lb = 0, ub = 10, qtype = "F4", len = N}):eval()
  local w = Q.rand({lb = 0, ub = 1, qtype = "F4", len = N}):eval()
  local loop_count = 16
  local A = {}
  local chunk_num = 0

  local start_time = qc.RDTSC()
  for i = 1, loop_count do
    A[i] = {}
    local temp = Q.vvmul(vec1, w)
    for j = i, loop_count do
      A[i][j] = Q.vvmul(vec1, temp)
    end
  end

  --[[
  for i = 1, loop_count do
    for j = i, loop_count do
      print(type(A[i][j]), A[i][j])
    end
  end
  ]]
  
  local base_len, base_addr, nn_addr
  repeat
    for i = 1, loop_count do
      for j = i, loop_count do
        base_len, base_addr, nn_addr = A[i][j]:chunk(chunk_num)
      end
    end
    chunk_num = chunk_num + 1
  until ( base_len ~= qconsts.chunk_size )
  print("Chunk case time = ", qc.RDTSC()-start_time)

  print(A)
  print("SUCCESS")
end

return tests
