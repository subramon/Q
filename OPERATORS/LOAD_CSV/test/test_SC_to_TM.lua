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
  local outv = Q.SC_to_TM(in_col, format):eval()
  assert(outv:fldtype() == "TM") 
  assert(outv:check())
  -- TODO More checking to be done
  
  print("Test t1 succeeded")
end
return tests
