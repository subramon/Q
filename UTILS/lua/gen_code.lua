local cutils  = require 'libcutils'
local qconsts = require 'Q/UTILS/lua/q_consts'

local section = { c = 'definition', h = 'declaration' }

local function do_replacements(subs)
  local tmpl = subs.tmpl
  local T
  assert(cutils.isfile(tmpl), "File not found " .. tmpl)
  T = assert(dofile(tmpl))
  for k, v in pairs(subs) do
     T[k] = v
  end
  return T
end

local _dotfile = function(subs, opdir, ext)
  assert(type(opdir) == "string")
  assert(#opdir > 0)
  if ( string.find(opdir, "/") == 1 ) then 
    -- fully qualified path
  else
    opdir = qconsts.Q_SRC_ROOT .. opdir
  end
  if ( not cutils.isdir(opdir) ) then
    assert(cutils.makepath(opdir))
  end
  assert(cutils.isdir(opdir))
  local T = do_replacements(subs)
  local dotfile = T(section[ext])
  local fname = opdir .. "/_" .. subs.fn .. "." .. ext
  local f = assert(io.open(fname, "w"))
  assert(f, "Unable to open file " .. fname)
  f:write(dotfile)
  f:close()
  return fname
end

local fns = {}

fns.dotc = function (subs, opdir)
  return _dotfile(subs, opdir, 'c')
end

fns.doth = function (subs, opdir )
  return _dotfile(subs, opdir, 'h')
end

return fns
