-- FUNCTIONAL
local Q = require 'Q'
local Scalar = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
require('Q/UTILS/lua/cleanup')()
require 'Q/UTILS/lua/strict'

-- the values of cum_cnt should be like a sawtooth
local function chk_sawtooth(
  x
  )
  assert(type(x) == "lVector")
  x:eval()
  local n = x:length()
  assert(n>0)
  local y = Q.is_prev(x, "leq", { default_val = 1 } )
  local z = Q.vseq(x, 1)
  local w = Q.vvor(y, z)
  -- Q.print_csv({x,y,z,w}, { opfile = "_x.csv" } )
  local n1, n2 = Q.sum(w):eval()
  -- print(n1, n2)
  assert(n1 == n2)
end

-- the values of cum_cnt should be between 1 and nR
local function chk_range(
  x
  )
  assert(type(x) == "lVector")
  x:eval()
  local n = x:length()
  assert(n>0)
  
  local n1, n2 = Q.sum(Q.vsleq(x, 0)):eval()
  
  assert(n1:to_num() == 0)

  local n1, n2 = Q.sum(Q.vsgt(x, n)):eval()
  assert(n1:to_num() == 0)
end

local tests = {}
tests.t1 = function()
  local val_qtype = "I4"
  local cnt_qtype = "I8"
  -- local len = qconsts.chunk_size * 2 + 17
  local len = 17
  local c1 = Q.seq({start = 1, by = 1, len = len, qtype = val_qtype })
  local c2 = Q.cum_cnt(c1, nil, { cnt_qtype = cnt_qtype } ):eval()
  local exp_c2 = Q.const({ val = 1, qtype = cnt_qtype, len=len})
  local n1, n2 = Q.sum(Q.vveq(c2, exp_c2)):eval()
  assert(n1 == n2)
  assert(c2:fldtype() == cnt_qtype)
  chk_range(c2)
  print("Test t1 succeeded")
end
tests.t2 = function()
  local val_qtype = "I4"
  local cnt_qtype = "I2"
  local c1 = Q.mk_col({1, 1, 2, 2, 3, 3, 4, 4, 5}, val_qtype):eval()
  local exp_c2 = Q.mk_col({1, 2, 1, 2, 1, 2, 1, 2, 1}, cnt_qtype):eval()
  local c2 = Q.cum_cnt(c1, nil, { cnt_qtype = cnt_qtype } ):eval()
  print(c2:fldtype(), cnt_qtype)
  assert(c2:fldtype() == cnt_qtype)
  -- Q.print_csv({c1, c2})
  local n1, n2 = Q.sum(Q.vveq(c2, exp_c2)):eval()
  assert(n1 == n2)
  chk_range(c2)
  print("Test t2 succeeded")
end
tests.t3 = function()
  local len = 1000000
  local lb = -32767
  local ub = 32767
  local x = Q.rand( { lb = lb, ub = ub, qtype = "I2", len = len })
  x = Q.sort(x, "asc")
  local y = Q.cum_cnt(x)
  assert(y:fldtype() == "I4")
  chk_range(y)
  chk_sawtooth(y)
  print("Test t3 succeeded")
end
return tests
