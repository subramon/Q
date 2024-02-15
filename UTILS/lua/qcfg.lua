local cutils = require 'libcutils'
local add_trailing_slash = require 'Q/UTILS/lua/add_trailing_slash'

local qcfg = {}
--===========================
-- Initialize environment variable constants
qcfg.q_src_root	= add_trailing_slash(os.getenv("Q_SRC_ROOT"))
qcfg.q_root	= add_trailing_slash(os.getenv("Q_ROOT"))

assert(cutils.isdir(qcfg.q_src_root))
assert(cutils.isdir(qcfg.q_root))

local qcflags = os.getenv("QCFLAGS") 
assert(type(qcflags) == "string")
assert(#qcflags > 32) -- some simple check 
qcfg.qcflags = qcflags
--==================================
qcfg.use_ispc = false
local x = os.getenv("QISPC") 
if ( x and x == "true" ) then 
  qcfg.use_ispc = true
else
  qcfg.use_ispc = false
end
if ( not os.getenv("QISPC_FLAGS") ) then
  qcfg.qispc_flags = " --pic "
else
  qcfg.qispc_flags = assert(os.getenv("QISPC_FLAGS"))
end
--==================================
qcfg.q_link_flags    = os.getenv("Q_LINK_FLAGS")
qcfg.ld_library_path = os.getenv("LD_LIBRARY_PATH")
--=================================
-- Note that no cell in an input CSV file can have length greater
-- than max_width_SC
qcfg.max_width_SC = 2048 -- => max length of constant length string = 32-1
qcfg.max_num_in_chunk = 4*32768 -- this is default value
local x = math.ceil(qcfg.max_num_in_chunk/64.0)
local y = math.floor(qcfg.max_num_in_chunk/64.0)
assert(x == y) -- MUST Be a multiple o 64

qcfg.debug = false -- set to TRUE only if you want debugging
-- Leave this as -1 unless you *REALLY* know what you are doing
qcfg.memo_len = -1 --  Vector code uses this default value
-- -1 means infinite memo, 0 means no memoization 
-- 1 means 1 previous chunk kept, 2 means 2 previous chunks and so on
-- TODO THINK qcfg.has_nulls = false -- Vector code uses this default value

qcfg.num_lives_kill = 0 -- default
qcfg.num_lives_free = 0 -- default
-- Following function used to modify qcfg at run time 
local function modify(key, val)
  if ( key == "num_lives_kill" ) then
    assert(type(val) == "number")
    assert(val >= 0)
    assert(val <= 16) -- some reasonable limit 
  elseif ( key == "num_lives_free" ) then
    assert(type(val) == "number")
    assert(val >= 0)
    assert(val <= 16) -- some reasonable limit 
  elseif ( key == "memo_len" ) then
    assert(type(val) == "number")
    if ( val < 0 ) then 
      assert(val == -1)
    end
  else
    assert("Unknown key " .. key)
  end
  qcfg[key] = val
end
qcfg._modify = modify 

return qcfg
