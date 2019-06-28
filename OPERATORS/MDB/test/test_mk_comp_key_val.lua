local Q = require 'Q'
local mk_kv = require 'Q/OPERATORS/MDB/lua/mk_comp_key_val'
local get_nDR = require 'Q/OPERATORS/MDB/lua/get_nDR'
local mk_in = require 'Q/OPERATORS/MDB/test/mk_mdb_input'
local mk_template = require 'Q/OPERATORS/MDB/lua/mk_template'

local tests = {}
tests.t1 = function()
  local Tk, n = mk_in.f1()
  assert(n)
  local nDR, vecs = get_nDR(Tk)
  local template, nR, nD, nC = mk_template(nDR)
  -- for k, v in  pairs(nDR) do print(k, v) end 
  -- for k, v in  pairs(vecs) do assert(type(v) == "lVector") end 
  --=============================================
  local val_vec = Q.seq({ start = 2, incr = 4, qtype = "F4", len = n})
  local key_vec, val_vec = mk_kv(Tk,  val_vec)
  assert(type(key_vec) == "lVector")
  assert(type(val_vec) == "lVector")
  key_vec:chunk(0)
  assert(key_vec:is_eov())
  assert(val_vec:is_eov())
  print(val_vec:length() ,n, nR)
  --assert(val_vec:length() == n * nR)
  
  print("Success on test t1")
end
return tests
