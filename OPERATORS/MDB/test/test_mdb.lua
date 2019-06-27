local Q = require 'Q'
local mdb = require 'Q/RUNTIME/AGG/lua/mdb'
local get_nDR = require 'Q/RUNTIME/AGG/lua/get_nDR'
local mk_in = require 'Q/RUNTIME/AGG/test/mk_mdb_input'

local tests = {}
tests.t1 = function()
  local Tk, n = mk_in.f1()
  assert(n)
  local nDR, vecs = get_nDR(Tk)
  -- for k, v in  pairs(nDR) do print(k, v) end 
  -- for k, v in  pairs(vecs) do assert(type(v) == "lVector") end 
  --=============================================
  local val_vec = Q.const({ val = 1, qtype = "F4", len = n})
  mdb(Tk,  val_vec)
  print("Success on test t1")
end

-- return tests
tests.t1()
