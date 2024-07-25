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
qcfg.is_memo = false; qcfg.memo_len = 0;
qcfg.is_killable = false; qcfg.num_kill_ignore = 0;
qcfg.is_early_freeable = false; qcfg.num_free_ignore = 0;
-- TODO THINK qcfg.has_nulls = false -- Vector code uses this default value

-- Following function used to modify qcfg at run time 
local function modify(key, val)
  if ( key == "memoable" ) then
    assert(type(val) == "table")
    assert(#val == 2)
    local is_memo = val[1]
    local memo_len = val[2]
    assert(type(is_memo ) == "boolean")
    assert(type(memo_len ) == "number")
    assert(#memo_len > 0)
    if ( not is_memo ) then 
      assert(memo_len == 0)
    end
    qcfg.is_memo = is_memo
    qcfg.memo_len = memo_len 
  elseif ( key == "killable" ) then
    assert(type(val) == "table")
    assert(#val == 2)
    local is_killable = val[1]
    local num_kill_ignore = val[2]
    assert(type(is_killable ) == "boolean")
    assert(type(num_kill_ignore ) == "number")
    assert(num_kill_ignore >= 0)
    if ( not is_killable ) then 
      assert(num_kill_ignore == 0)
    else
      assert(num_kill_ignore <= 16) -- some reasonable limit 
    end
    qcfg.is_killable = is_killable
    qcfg.num_kill_ignore = num_kill_ignore 
  elseif ( key == "early_freeable" ) then
    assert(type(val) == "table")
    assert(#val == 2)
    local is_early_freeable = val[1]
    local num_free_ignore = val[2]
    assert(type(is_early_freeable ) == "boolean")
    assert(type(num_free_ignore ) == "number")
    assert(num_free_ignore >= 0)
    if ( not is_early_freeable ) then 
      assert(num_free_ignore == 0)
    else
      assert(num_free_ignore <= 16) -- some reasonable limit 
    end
    qcfg.is_early_freeable = is_early_freeable
    qcfg.num_free_ignore = num_free_ignore 
  else
    assert("Unknown key " .. key)
  end
  return true
end
qcfg._modify = modify 

return qcfg
