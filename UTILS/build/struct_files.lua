-- NOTE: Important. All struct files need to be listed here.
-- For each file, verify that it exists and copy it to 
-- Q_BUILD_DIR/include/
local qconsts = require 'Q/UTILS/lua/q_consts'
local cutils  = require 'libcutils'

local root = assert(qconsts.Q_SRC_ROOT)
assert(cutils.isdir(root))

local destdir = assert(qconsts.Q_BUILD_DIR)
assert(cutils.isdir(destdir))
destdir = destdir .. "/include/" 
assert(cutils.isdir(destdir))

local T = {
  "UTILS/inc/q_constants.h",  -- not struct files but treated the same
  "UTILS/inc/q_macros.h",     -- not struct files but treated the same
  "UTILS/inc/q_incs.h"        -- not struct files but treated the same
  "RUNTIME/VCTR/inc/core_vec_struct.h",
  "RUNTIME/SCLR/inc/scalar_struct.h",
  "RUNTIME/CMEM/inc/cmem_struct.h",
  "UTILS/inc/spooky_struct.h",  
  "UTILS/inc/drand_struct.h",  
  "OPERATORS/S_TO_F/inc/const_struct.h",  
  "OPERATORS/S_TO_F/inc/seq_struct.h",   
  "OPERATORS/S_TO_F/inc/rand_struct.h",   
  "OPERATORS/S_TO_F/inc/period_struct.h", 
  "OPERATORS/F_TO_S/inc/minmax_struct.h", 
  "OPERATORS/F_TO_S/inc/sum_struct.h",    
  "ML/DT/inc/dt_benefit_struct.h", 
  "ML/DT/inc/evan_dt_benefit_struct.h", 
}
local T0 = {}
local T1 = {}
local T2 = {}
for _, v in ipairs(T) do 
  local src = root .. "/" .. v
  assert(cutils.isfile(src), src)
  local fname = string.gsub(v, "^.*/", "")
  local dst = destdir .. fname
  assert(cutils.copyfile(src, dst))
  --=====
  T0[#T0+1] = fname
  T1[#T1+1] = src
  T2[#T2+1] = dst

end
return T0, T1, T2
