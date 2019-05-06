-- FUNCTIONAL
local Q       = require 'Q'
local cmem    = require 'libcmem'
local Vector  = require 'libvec'
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function ()
  local buf = cmem.new(128, "SC", "string buffer")
  local str_val = "2001-11-12 18:31:01"
  local format = "%Y-%m-%d %H:%M:%S"

  local width = 64
  buf:zero()
  buf:set(str_val)
  local y = assert(Vector.new('SC:' .. width, qconsts.Q_DATA_DIR))
  local len  = 2*qconsts.chunk_size + 17
  for j = 1, len do 
    assert(y:put1(buf))
  end
  y:eov()
  y:persist()
  local file_size = y:file_size()
  local file_name = y:file_name()
  local in_col = lVector({file_name = file_name, qtype = "SC",
    width = width})
  local out_col = Q.SC_to_TM(in_col, format):eval()
  assert(out_col:fldtype() == "TM") 
  assert(out_col:check())
  -- TODO P3 More checking to be done
  -- Now go the other way
  local chk_in_col = Q.TM_to_SC(out_col, format):eval()
  -- Q.print_csv({in_col, chk_in_col})
  
  print("Test t1 succeeded")
end
return tests
