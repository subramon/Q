local cutils       = require 'libcutils'
local qconsts      = require 'Q/UTILS/lua/q_consts'
local exec         = require 'Q/UTILS/lua/exec_and_capture_stdout'

local QISPC_FLAGS  = assert(qconsts.QISPC_FLAGS)
local QC_FLAGS     = assert(qconsts.QC_FLAGS)
local Q_SRC_ROOT   = qconsts.Q_SRC_ROOT

-- some basic checks
assert(cutils.isdir(Q_SRC_ROOT))
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
    dotc = Q_SRC_ROOT .. "/" .. dotc
  end
  assert(cutils.isfile(dotc), dotc)
  --===================================
  local str_incs = {}
  if ( incs ) then
    for _, v in ipairs(incs) do
      local incdir = qconsts.Q_SRC_ROOT .. v
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
      local srcfile = qconsts.Q_SRC_ROOT .. v
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
         QC_FLAGS, str_incs, dotc, doto)
      assert(exec(q_cmd), q_cmd)
    end
    if ( lang == "ISPC" ) then
      print(" QISPC_FLAGS " ..  QISPC_FLAGS)
      q_cmd = string.format("ispc %s %s %s -o %s",
         QISPC_FLAGS, str_incs, dotc, doto)
    end
    print("compiling ", q_cmd)
    local status = os.execute(q_cmd)
    assert(status == 0)
    assert(cutils.isfile(doto))
    dotos[#dotos+1] = doto
  end
  return dotos
end
return compile
