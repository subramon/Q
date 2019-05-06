--functional test
local Q = require 'Q'
local utils = require 'Q/UTILS/lua/utils'
local qconsts = require 'Q/UTILS/lua/q_consts'

local tests = {}

tests.t1 = function()
  local tbl = {10,20,30,40,50,60,70,80,90,100}
  local qtype = "I1"
  local vec = utils.table_to_vector(tbl, qtype)
  assert(type(vec) == 'lVector', "output not of type lVector")
  assert(vec:num_elements() == #tbl, "table and vector length not same")
end

tests.t2 = function()
  local tbl = {}
  local qtype = "I4"
  
  for i = 1, 65540 do
    tbl[#tbl+1] = ( i * 10 ) % qconsts.qtypes[qtype].max
  end
  
  local vec = Q.mk_col(tbl, qtype)
  local status, res = pcall(utils.vector_to_table,vec)
  assert(status == false, res)
end

return tests
