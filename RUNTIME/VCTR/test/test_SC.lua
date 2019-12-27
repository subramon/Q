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
-- testing put1 and get1 
tests.t1 = function()
  local qtype = "SC"
  local width = 4 -- remember 1 byte for nullc
  local v = cVector.new( { qtype = qtype, width = width} )
  --=============
  local n = chunk_size + 1
  local exp_num_chunks = 0
  local exp_num_elements = 0
  -- put elements as 1, 2, 3, ...
  local s = cmem.new(4, "SC")
  s:zero()
  ffi.cdef("char *strcpy(char *dest, const char *src);");
  local sp = ffi.cast("char *", get_ptr(s))
  ffi.C.strcpy(sp, "ABC")
  for i = 1, n do 
    assert(v:put1(s))
  end
  --================
  -- make sure you get what you put
  for i = 1, n do 
    local s = v:get1(i-1)
    assert(type(s) == "CMEM")
    local sp = ffi.cast("CMEM_REC_TYPE *", s)
    assert(sp.width == width)
    assert(ffi.string(sp.fldtype) == "SC")
    assert(ffi.string(sp.data) == "ABC")
    assert(s:fldtype() == "SC")
    -- TODO assert(s:to_num() == i, i)
  end
  --================
  v:persist()
  v:eov()
  local x = v:shutdown() 
  assert(type(x) == "string") 
  assert(#x > 0)
  y = loadstring(x)()
  assert(y.num_elements == n)
  assert(y.field_width == width)
  assert(y.fldtype == qtype)
  if ( iter == 1 ) then 
    assert(not y.file_name)
    assert(type(y.file_names) == "table")
    assert(#y.file_names == num_chunks)
    for k, v in pairs(y.file_names) do 
      assert(plpath.isfile(v)) 
    end
  end
  print("Successfully completed test t1")
end
-- return tests

tests.t1() 
os.exit()

