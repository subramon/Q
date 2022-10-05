local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local isby   = require 'Q/OPERATORS/GROUPBY/lua/isby'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function()
  local src_len = 100 
  local svtbl = {}
  for i = 1, src_len do svtbl[i] = i*10 end 
  local sv = mk_col(svtbl, "I4", { max_num_in_chunk = 8 })

  local sltbl = {}
  for i = 1, src_len do sltbl[i] = i end 
  local sl = mk_col(sltbl, "I8", { max_num_in_chunk = 8 })

  local dst_len = 20 
  local dltbl = {}
  for i = 1, dst_len do dltbl[i] = (i+1)*4 end 
  local dl = mk_col(dltbl, "I8", { max_num_in_chunk = 16 })

  local dv = isby(sv, sl, dl):eval()
  assert(type(dv) == "lVector")
  assert(dv:has_nulls() == true)
  assert(dv:qtype() == sv:qtype())
  assert(dv:max_num_in_chunk() == dl:max_num_in_chunk())
  assert(dv:num_elements() == dl:num_elements())

  print("Test t1 successfully completed")
end
tests.t1()
-- return tests
