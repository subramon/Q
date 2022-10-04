local mk_col = require 'Q/OPERATORS/MK_COL/mk_col'
local isby   = require 'Q/OPERATORS/GROUPBY/isby'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function()
  local src_len = 100 
  local svtbl = {}
  for i = 1, src_len do svtbl[i] = i*10 end 
  local sv = Q.mk_col(svtbl, "I4")

  local sltbl = {}
  for i = 1, src_len do svtbl[i] = i end 
  local sl = Q.mk_col(sltbl, "I8")

  local dst_len = 20 
  local dltbl = {}
  for i = 1, dst_len do svtbl[i] = (i+1)*8 end 
  local dl = Q.mk_col(dltbl, "I8")

  local dv = Q.isby(sv, sl, dl):eval()
  assert(type(dv) == "lVector")
  assert(dv:qtype() == sv:qtype())
  assert(dv:num_elements() == dl:num_elements())
  dv:pr()

  print("Test t1 successfully completed")
end
tests.t1()
-- return tests
