local cutils        = require 'libcutils'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local assertx       = require 'Q/UTILS/lua/assertx'
local clean_h_file  = require 'Q/UTILS/lua/clean_h_file'
local exec          = require 'Q/UTILS/lua/exec_and_capture_stdout'

local QC_FLAGS     = qconsts.QC_FLAGS
local Q_ROOT       = qconsts.Q_ROOT 
local Q_SRC_ROOT   = qconsts.Q_SRC_ROOT
local Q_BUILD_DIR  = qconsts.Q_BUILD_DIR
local Q_LINK_FLAGS = qconsts.Q_LINK_FLAGS

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
  local sofile = lib_prefix .. fn .. ".so" -- to be created 
  if ( cutils.isfile(sofile) ) then 
    print("File exists: No need to create " .. sofile)
    return sofile
  end
  -- START: Error checking on inputs
  assert(cutils.isfile(dotc))
  if ( structs ) then 
    assert(type(structs) == "table")
    for k, v in ipairs(structs) do 
      assert(cutils.isfile(v))
    end
  end
  --===============================
  local str_incs = {}
  for _, v in ipairs(incs) do 
    local incdir = qconsts.Q_SRC_ROOT .. v
    assert(cutils.isdir(incdir))
    str_incs[#str_incs+1] = "-I" .. incdir
  end
  str_incs = table.concat(str_incs, " ")
  --===============================
  local str_srcs = {}
  for k, v in ipairs(srcs) do 
    local srcfile = qconsts.Q_SRC_ROOT .. v
    assert(cutils.isfile(srcfile))
    str_srcs[#str_srcs+1] = srcfile 
  end
  str_srcs = table.concat(str_srcs, " ")
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
  -- Now, we need to make sure .h file is in place so that when server
  -- restarts, we can pick up the .h file and .so file are present
  -- and can be loaded and we do not compile mid-way through execution
  -- No need for get_func_decl(), clean_h_file is enough because
  -- we do not need to run through cpp because (for now) no constants 
  -- to worry about
  --[[ TODO P1
  local h_file = clean_h_file(tmp_h) 
  cutils.write(hfile, h_file)
  --]]
  return sofile 
end
return compile
