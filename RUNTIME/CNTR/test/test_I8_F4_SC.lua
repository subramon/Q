local cutils = require 'libcutils'
local plutils= require 'pl.utils'
local plfile = require 'pl.file'
local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local ffi     = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local KeyCounter = require 'Q/RUNTIME/CNTR/lua/KeyCounter'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local lgutils  = require 'liblgutils'
--=======================================================
local rootdir = assert(os.getenv("Q_SRC_ROOT")) 
local tests = {}
tests.t1 = function()
  local M = {}
  local O = { is_hdr = true }
  -- TODO P1 Test with different memo_len values 
  M[#M+1] = { name = "i8", qtype = "I8", memo_len = -1 }
  M[#M+1] = { name = "f4", qtype = "F4", memo_len = -1  }
  M[#M+1] = { name = "sc", qtype = "SC", width = 16, memo_len = -1  }
  local datafile = qcfg.q_src_root .. "/RUNTIME/CNTR/test/in1.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  assert(type(T) == "table")
  for k, v in pairs(T) do print(k, v) end 
  assert(type(T.i8) == "lVector")
  -- convert to indexed table 
  local Tpr = {}
  for k, v in pairs(T) do 
    Tpr[#Tpr+1] = v
  end
  -- clean out old stuff
  local label = "t1_i8_f4_sc"
  local opdir=rootdir .. "/TMPL_FIX_HASHMAP/KEY_COUNTER/" .. label 
  os.execute("rm -r -f " .. opdir)
  -- create a KeyCounter
  local optargs = {}
  optargs.label = label
  optargs.name  = "i8_f4_sc"
  local C = KeyCounter(Tpr, optargs)
  assert(type(C) == "KeyCounter")
  assert(C:size() > 0)
  assert(C:nitems() == 0)
  assert(C:label() == optargs.label)
  assert(C:name()  == optargs.name)
  assert(C:is_eor() == false)
  -- evaluate the KeyCounter
  assert(C:eval())
  print(C:nitems())
  -- get some items to make sure C is working well 
  -- Look for something that *IS there 
  local key, keytype, val, valtype, is_found, where_found = 
    C:get_val({123,456,"hello world 1"})
    print(keytype)
    print(valtype)
    error("PREMATURE")
  key = ffi.cast(keytype .. " *", key)
  assert(key.key1 == 1)
  assert(key.key2 == 2)
  assert(C:nitems() == 3)
  --[[
  T.i8:eval()
  assert(T.i8:num_elements() == T.f4:num_elements())
  print("XX", T.sc:num_elements())
  Q.print_csv(Tpr, {opfile = "_x.csv"})
  --]]
  for k, v in pairs(T) do v:delete() end; T = nil ; Tpr = nil
  print("Test t1 succeeded")
end
tests.t1()
-- return tests
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
