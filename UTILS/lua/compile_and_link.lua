local cutils     = require 'libcutils'
local qcfg       = require 'Q/UTILS/lua/qcfg'
local exec       = require 'RSUTILS/lua/exec_and_capture_stdout'
local c_exec     = require 'RSUTILS/lua/c_exec'
local is_so_file = require 'Q/UTILS/lua/is_so_file'

local qcflags   = qcfg.qcflags
local q_src_root = qcfg.q_src_root

-- some basic checks
assert(cutils.isdir(q_src_root))
--================================================
-- This is used to create the .so file for a function "foo"
-- The name of the sofile created is returned
-- The function "foo" is provided in the file dotc
-- srcs is an optional table consisting of other functions 
-- needed by foo()
-- incs is an optional table consisting of directories in which
-- header files included by the .c files will be found 
-- libs is an optional table consisting of other libraries needed
-- For example, we may need to link in the math library in which case
-- libs = { "-lm", }
local function compile_and_link(
  dotc,  -- INPUT
  srcs, -- INPUT, any other files to be compiled
  incs, -- INPUT, where to look for include files
  libs,-- INPUT, any libraries that need to be linked
  fn -- INPUT
  )
  if ( string.sub(dotc, 1, 1) ~= "/" ) then
    -- we do not have fully qualified path
    dotc = qcfg.q_src_root .. dotc
  end
  assert(cutils.isfile(dotc), "ERROR: File not found " .. dotc)
  local is_so, sofile = is_so_file(fn)
  if ( is_so ) then
    print("File exists: No need to create " .. sofile)
    return sofile
  end
  --===============================
  local str_incs = {}
  if ( incs ) then
    for _, v in ipairs(incs) do
      local incdir 
      if ( string.sub(v, 1, 1) ~= "/") then 
        -- we do not have fully qualified path
        incdir = qcfg.q_src_root .. v
      else
        incdir = v
      end 
      assert(cutils.isdir(incdir), incdir)
      str_incs[#str_incs+1] = "-I" .. incdir
    end
    str_incs = table.concat(str_incs, " ")
  else
    str_incs = ""
  end
  --===============================
  local str_srcs = {}
  if ( srcs ) then
    for _, srcfile in ipairs(srcs) do
      if ( string.sub(srcfile, 1, 1) ~= "/" ) then 
        srcfile = qcfg.q_src_root .. srcfile
      end 
      assert(cutils.isfile(srcfile), "File not found " .. srcfile)
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
  if ( cutils.isfile(sofile) ) then 
    print("not recompiling. File exists " .. sofile)
  else
    local q_cmd = string.format("gcc -shared %s %s %s %s -o %s %s",
       qcflags, str_incs, dotc, str_srcs, sofile, str_libs)
       print("q_cmd = ", q_cmd)
    local cmd_out = c_exec(q_cmd)
    if ( not cmd_out ) then
      -- TODO P1 Need to understand this better 
      print("WARNING! Ignoring error for q_cmd = ", q_cmd)
    end
  end
  assert(cutils.isfile(sofile))
  return sofile
end
return compile_and_link
