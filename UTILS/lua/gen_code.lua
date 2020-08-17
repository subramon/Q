local cutils  = require 'libcutils'
-- local plpath  = require 'pl.path'
-- local pldir   = require 'pl.dir'
local qconsts = require 'Q/UTILS/lua/q_consts'

local section = { 
  c = 'definition', 
  h = 'declaration',
  ispc = 'definition', 
  }

local function do_replacements(subs, lang)
  assert ( ( lang == "C" ) or ( lang == "ISPC" ) ) 
  local tmpl
  if ( lang == "C" ) then tmpl = assert(subs.tmpl) end 
  if ( lang == "ISPC" ) then tmpl = assert(subs.tmpl_ispc) end 
  if ( string.find(tmpl, "/") ~= 1 ) then -- TODO P4: What if no '/'? 
    tmpl = qconsts.Q_SRC_ROOT .. tmpl
  end
  local T
  assert(cutils.isfile(tmpl), "File not found " .. tmpl)
  T = assert(dofile(tmpl))
  for k, v in pairs(subs) do
     T[k] = v
  end
  return T
end

local _dotfile = function(subs, opdir, lang, ext)
  assert(type(opdir) == "string")
  assert(#opdir > 0)
  local func_name = subs.fn
  local basic_fname = opdir .. "/" .. func_name .. "." .. ext
  if ( string.find(opdir, "/") ~= 1 ) then -- TODO P4: What if no '/' ?
    opdir = qconsts.Q_SRC_ROOT .. opdir
  end
  if ( not cutils.isdir(opdir) ) then
    assert(cutils.makepath(opdir))
  end
  assert(cutils.isdir(opdir))
  local T = do_replacements(subs, lang)
  local dotfile = T(section[ext])
  local fname = opdir .. "/" .. func_name .. "." .. ext
  local f = assert(io.open(fname, "w"))
  assert(f, "Unable to open file " .. fname)
  f:write(dotfile)
  f:close()
  -- Note that we return basic_fname, not fname for consistency reasons
  return basic_fname, fname
end

local fns = {}

fns.dotc = function (subs, opdir)
  return _dotfile(subs, opdir, "C", 'c')
end

fns.doth = function (subs, opdir)
  return _dotfile(subs, opdir, "C", 'h')
end

fns.ispc = function (subs, srcdir, incdir)
  -- this will return .ispc file and .h file 
  -- first create the .ispc file 
  local ispc_basic, ispc_full =  _dotfile(subs, srcdir, "ISPC", 'ispc')
  -- now create the .h file
  -- first, create its name (rather ugly repetition)
  local func_name = subs.fn_ispc
  local h_basic = incdir .. "/" .. func_name .. ".h"
  if ( string.find(incdir, "/") ~= 1 ) then -- TODO P4: What if no '/' ?
    incdir = qconsts.Q_SRC_ROOT .. incdir
  end
  if ( not cutils.isdir(incdir) ) then
    assert(cutils.makepath(incdir))
  end
  local h_full = incdir .. "/" .. func_name .. ".h" 
  -- now we use ispc to create the .h file 
  local cmd = "ispc " .. ispc_full .. " -h " .. h_full .. " 1>/dev/null 2>&1"
  print("ispc making .h file", cmd)
  local status = os.execute(cmd)
  assert(status == 0)
  return ispc_basic, h_basic

end
return fns
