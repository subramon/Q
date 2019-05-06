-- FUNCTIONAL
local Q = require 'Q'

local Scalar = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
local json    = require 'Q/UTILS/lua/json'
local view_meta = require 'Q/UTILS/lua/view_meta'
local tests = {}
tests.t1 = function()
  c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
  c2 = Q.mk_col( {20,35,26,50,11,30,45,17}, "I4")
  z = Q.vvadd(c1, c2)
  -- Below case supported as sort performs eval if vector is not eval'ed
  -- So commenting below assert
  local status = pcall(Q.sort, z, "asc")
  --assert(not status )
  z:eval()
  Q.sort(z, "asc")
  z:set_meta("max", Q.max(c2):eval())
  z:set_meta("min", Q.min(c2):eval())
  local x, y = Q.view_meta()
  assert(type(x) == "table")
  local xctr = 0
  for k, v in pairs(x) do 
    xctr = xctr + 1 
  end
  assert(xctr == 3)
  local w = assert(json.parse(y))
  assert(tonumber(w.z.aux.min) == Q.min(c2):eval():to_num())
  assert(tonumber(w.z.aux.max) == Q.max(c2):eval():to_num())
end
--======================================
return tests
