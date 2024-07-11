local cutils   = require 'libcutils'
local qcfg     = require 'Q/UTILS/lua/qcfg'
local exec     = require 'RSUTILS/lua/exec_and_capture_stdout'
local c_exec   = require 'RSUTILS/lua/c_exec'

local qispc_flags  = assert(qcfg.qispc_flags)
local qcflags     = assert(qcfg.qcflags)
local q_src_root   = qcfg.q_src_root

-- some basic checks
assert(cutils.isdir(q_src_root))
--================================================
local function compile(
  lang,
  dotc,  -- INPUT
  srcs, -- INPUT, any other files to be compiled
  incs, -- INPUT, where to look for include files
  dotos
  )
  dotos = dotos or {}
  assert ( ( lang == "C" ) or ( lang == "ISPC" ) )
  if ( string.find(dotc, "/") ~= 1 ) then -- TODO P4: What if no '/'?
    -- we do not have fully qualified path
    dotc = q_src_root .. "/" .. dotc
  end
  assert(cutils.isfile(dotc), dotc)
  --===================================
  local str_incs = {}
  if ( incs ) then
    for _, v in ipairs(incs) do
      local incdir = qcfg.q_src_root .. v
      assert(cutils.isdir(incdir), incdir)
      str_incs[#str_incs+1] = "-I" .. incdir
    end
    str_incs = table.concat(str_incs, " ")
  else
    str_incs = " "
  end
  --===============================
  -- make a table of all source files to be compiled
  local xsrcs = {}
  if ( srcs ) then
    for _, v in ipairs(srcs) do
      local srcfile = qcfg.q_src_root .. v
      assert(cutils.isfile(srcfile))
      xsrcs[#xsrcs+1] = srcfile
    end
  end
  xsrcs[#xsrcs+1] = dotc
  --===============================
  for _, srcfile in ipairs(xsrcs) do
    local q_cmd
    local doto = "/tmp/" .. cutils.basename(srcfile) .. ".o"
    if ( lang == "C" ) then
      q_cmd = string.format("gcc -c %s %s %s -o %s",
         qcflags, str_incs, dotc, doto)
      -- OLD assert(exec(q_cmd), q_cmd)
      assert(c_exec(q_cmd), q_cmd)
    end
    if ( lang == "ISPC" ) then
      -- print(" qispc_flags " ..  qispc_flags)
      q_cmd = string.format("ispc %s %s %s -o %s",
         qispc_flags, str_incs, dotc, doto)
    end
    -- print("compiling ", q_cmd)
    if ( ( lang == "ISPC" ) and ( qcfg.use_ispc == false ) ) then 
      -- do nothing 
    else
      local status = os.execute(q_cmd)
      assert(status == 0)
      assert(cutils.isfile(doto))
      dotos[#dotos+1] = doto
    end
  end
  return dotos
end
return compile
