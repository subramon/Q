local cutils = require 'libcutils'
local add_trailing_bslash = require 'Q/UTILS/lua/add_trailing_bslash'

local qcfg = {}
--===========================
-- Initialize environment variable constants
qcfg.q_src_root	= add_trailing_bslash(os.getenv("Q_SRC_ROOT"))
qcfg.q_root	= add_trailing_bslash(os.getenv("Q_ROOT"))

assert(cutils.isdir(qcfg.q_src_root))
assert(cutils.isdir(qcfg.q_root))

if ( not os.getenv("QC_FLAGS") ) then
  qcfg.qc_flags = [[
-g -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align
-Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings
-Wunused-variable -Wunused-parameter -Wno-pedantic
-fopenmp -mavx2 -mfma -Wno-unused-label
-fsanitize=address -fno-omit-frame-pointer
-fsanitize=undefined
-Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith
-Wmissing-declarations -Wredundant-decls -Wnested-externs
-Wshadow -Wcast-qual -Wcast-align -Wwrite-strings
-Wold-style-definition
-Wsuggest-attribute=noreturn
-Wduplicated-cond -Wmisleading-indentation -Wnull-dereference
-Wduplicated-branches -Wrestrict
  ]]
else
  qcfg.qc_flags	= assert(os.getenv("QC_FLAGS"))
end
--==================================
if ( not os.getenv("QISPC_FLAGS") ) then
  qcfg.qispc_flags = " --pic "
else
  qcfg.qispc_flags = assert(os.getenv("QISPC_FLAGS"))
end
--==================================
qcfg.q_link_flags    = os.getenv("Q_LINK_FLAGS")
qcfg.ld_library_path = os.getenv("LD_LIBRARY_PATH")
--=================================
qcfg.debug = true -- set to TRUE only if you want debugging
qcfg.is_memo = true -- Vector code uses this default value
qcfg.has_nulls = false -- Vector code uses this default value

local function modify(key, val)
  qcfg[key] = val
end
qcfg._modify = modify 

return qcfg
