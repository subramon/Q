local cutils        = require 'libcutils'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local assertx       = require 'Q/UTILS/lua/assertx'
local exec          = require 'Q/UTILS/lua/exec_and_capture_stdout'

local QC_FLAGS     = qconsts.QC_FLAGS
local Q_ROOT       = qconsts.Q_ROOT
local Q_SRC_ROOT   = qconsts.Q_SRC_ROOT

local lib_prefix = Q_ROOT .. "/lib/lib"

-- some basic checks
assert(cutils.isdir(Q_SRC_ROOT))
--================================================
local function compile(
  dotc,  -- INPUT
  srcs, -- INPUT, any other files to be compiled
  incs, -- INPUT, where to look for include files
  libs, -- INPUT, any libraries that need to be linked
  fn -- INPUT
  )
  -- TODO P4: What if no forward slash in dotc?
  if ( string.find(dotc, "/") ~= 1 ) then
    -- we do not have fully qualified path
    dotc = Q_SRC_ROOT .. "/" .. dotc
  end
  assert(cutils.isfile(dotc), dotc)
  local sofile = lib_prefix .. fn .. ".so" -- to be created
  if ( cutils.isfile(sofile) ) then
    -- print("File exists: No need to create " .. sofile)
    return sofile
  end
  --===============================
  local str_incs = {}
  if ( incs ) then 
  for _, v in ipairs(incs) do
    local incdir = qconsts.Q_SRC_ROOT .. v
    assert(cutils.isdir(incdir))
    str_incs[#str_incs+1] = "-I" .. incdir
  end
    str_incs = table.concat(str_incs, " ")
  else
    str_incs = ""
  end
  --===============================
  local str_srcs = {}
  if ( srcs ) then
    for _, v in ipairs(srcs) do
      local srcfile = qconsts.Q_SRC_ROOT .. v
      assert(cutils.isfile(srcfile))
      str_srcs[#str_srcs+1] = srcfile
    end
    str_srcs = table.concat(str_srcs, " ")
  else
    str_srcs = ""
  end
  --===============================
  local str_libs = ""
  if ( libs ) then
    str_libs = table.concat(libs, " ")
  end
  --===============================
  local q_cmd = string.format("gcc -shared %s %s %s %s -o %s %s",
       QC_FLAGS, str_incs, dotc, str_srcs, sofile, str_libs)
  assert(exec(q_cmd), q_cmd)
  assertx(cutils.isfile(sofile), "Target " ..  sofile .. " not created")
  return sofile
end
return compile
