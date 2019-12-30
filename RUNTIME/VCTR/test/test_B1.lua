local cutils = require 'libcutils'
local plpath = require 'pl.path'
local ffi     = require 'ffi'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/q_consts'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local get_func_decl = require 'Q/UTILS/build/get_func_decl'

local hdrs = get_func_decl("../inc/core_vec_struct.h", " -I../../../UTILS/inc/")
ffi.cdef(hdrs)
-- following only because we are testing. Normally, we get this from q_core
local hdrs = get_func_decl("../../CMEM/inc/cmem_struct.h", " -I../../../UTILS/inc/")
ffi.cdef(hdrs)

--=================================
local chunk_size = 65536
local params = { chunk_size = chunk_size, sz_chunk_dir = 4096, 
    data_dir = qconsts.Q_DATA_DIR }
assert(cVector.init_globals(params))
--=================================
local tests = {}
-- testing put1 and get1 for B1

tests.t0 = function(incr)
  if ( not  incr ) then incr = 0 end 
  local qtype = "B1"
  local width = 1
  local v = cVector.new( { qtype = qtype, width = width } )
  --=============
  local n = chunk_size + incr
  local exp_num_chunks = 0
  local exp_num_elements = 0
  -- put elements alternating between true and false
  local s0 = Scalar.new(0, "B1")
  local s1 = Scalar.new(1, "B1")
  local alternate = false
  for i = 1, n do 
    if ( alternate == true ) then 
      assert(v:put1(s1))
      alternate = false
    else 
      assert(v:put1(s0))
      alternate = true
    end
  end
  --================
  -- make sure you get what you put
  local alternate = false
  for i = 1, n do 
    local s = v:get1(i-1)
    assert(type(s) == "Scalar")
    assert(s:fldtype() == "B1")
    if ( alternate == true ) then 
      assert(s == s1)
      alternate = false
    else 
      assert(s == s0)
      alternate = true
    end
  end
  --================
  v:persist()
  v:eov()
  v:check()
  cVector:check_chunks()
  local x = v:shutdown() 
  assert(v:is_dead())
  assert(type(x) == "string") 
  assert(#x > 0)
  y = loadstring(x)()
  assert(type(y) == "table")
  assert(y.num_elements == n)
  assert(y.width == width)
  assert(y.qtype == qtype)
  if ( iter == 1 ) then 
    assert(not y.file_name)
    assert(type(y.file_names) == "table")
    assert(#y.file_names == num_chunks)
    for k, v in pairs(y.file_names) do 
      assert(plpath.isfile(v)) 
    end
  end
  local z = assert(cVector.rehydrate(y))
  print("Successfully rehydrated")
  assert(z:num_elements() == n)
  assert(z:field_width() == width)
  assert(z:fldtype() == qtype)
  local alternate = false
  for i = 1, n do
    local s = z:get1(i-1)
    assert(type(s) == "Scalar")
    if ( alternate == true ) then 
      assert(s == s1)
      alternate = false
    else 
      assert(s == s0)
      alternate = true
    end
  end
  z:check()
  cVector:check_chunks()

  print("Successfully completed test t0 with n = ", n )
  return true
end

tests.t1 = function()
  assert(tests.t0(-1))
  assert(tests.t0(1))
  print("Successfully completed test t1")
end
-- return tests

tests.t0() 
tests.t1() 
os.exit()

