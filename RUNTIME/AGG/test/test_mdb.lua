local Q = require 'Q'
local mdb = require 'Q/RUNTIME/AGG/lua/mdb'
local get_nDR = require 'Q/RUNTIME/AGG/lua/get_nDR'

local tests = {}
tests.t1 = function()
  local Tk = require 'mdb_in_1'
  local nDR, vecs = get_nDR(Tk)
  -- for k, v in  pairs(nDR) do print(k, v) end 
  -- for k, v in  pairs(vecs) do assert(type(v) == "lVector") end 
  --=============================================
  print("Success on test t1")
end

-- return tests
tests.t1()
