-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local ffi = require 'Q/UTILS/lua/q_ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local linear_solver = require 'Q/OPERATORS/AX_EQUALS_B/lua/linear_solver'

local mk_cols = function(A)
  local B = {}
  for i, ci in ipairs(A) do
    B[i] = Q.mk_col(ci, 'F8')
  end
  return B
end

local tests = {}

tests.t1 = function()
  local A_bare = {
    { 5, -1, 3.5, 4.2 },
    { 0, -6.2, 4, 3.7 },
    { -2, 5, 3, 2 },
    { -5, -4, -3, -2 }
  }
  local A = mk_cols(A_bare)
  local b_bare = { 3, 0, 7, 10 }
  local b = Q.mk_col(b_bare, 'F8')

  local x = linear_solver.general(A, b)
  local b_new = Q.mv_mul(A, x)
  b_new:eval()
  local _, b_new_chunk, _ = b_new:get_all()
  b_new_chunk = ffi.cast("double*", get_ptr(b_new_chunk))
  for i, bi in ipairs(b_bare) do
    assert(math.abs(bi - b_new_chunk[i - 1]) < 0.001, "Ax ~= b")
  end
end

return tests
