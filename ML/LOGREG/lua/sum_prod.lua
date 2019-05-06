local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'

function sum_prod(X, w)
  local temp = {}
  local SA = {}
  local M = #X
  local A = {}

  for i = 1, M do
    SA[i] = {}
    A[i] = {}
    temp[i] = Q.vvmul(X[i], w) -- :memo(false)
    for j = i, M do
      SA[i][j] = Q.sum(Q.vvmul(X[j], temp[i])) -- :memo(false))
    end
  end
  local len = w:length()
  local chunk_size = qconsts.chunk_size

  local nC = math.ceil( len / chunk_size )
  
  for c = 1, nC do
    for i = 1, M do
      temp[i]:chunk(c-1) -- get this chunk evaluated
      for j = i, M do
        SA[i][j]:next() -- get this chunk evaluated
      end
    end
  end
  for i = 1, M do
    for j = i, M do
      A[i][j] = SA[i][j]:value() -- get the value evaluated
    end
  end

  return A
end
return sum_prod
