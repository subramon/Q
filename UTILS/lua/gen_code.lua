local cutils  = require 'libcutils'
-- local plpath  = require 'pl.path'
-- local pldir   = require 'pl.dir'
local qconsts = require 'Q/UTILS/lua/q_consts'

local section = { c = 'definition', h = 'declaration' }

local function do_replacements(subs)
  local tmpl = subs.tmpl
  if ( string.find(tmpl, "/") == 1 ) then 
    -- fully qualified path
  else
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

local _dotfile = function(subs, opdir, ext)
  assert(type(opdir) == "string")
  assert(#opdir > 0)
  local basic_fname = opdir .. "/" .. subs.fn .. "." .. ext
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
  local fname = opdir .. "/" .. subs.fn .. "." .. ext
  local f = assert(io.open(fname, "w"))
  assert(f, "Unable to open file " .. fname)
  f:write(dotfile)
  f:close()
  -- Note that we return basic_fname, not fname for consistency reasons
  return basic_fname
end

local fns = {}

fns.dotc = function (subs, opdir)
  return _dotfile(subs, opdir, 'c')
end

fns.doth = function (subs, opdir )
  return _dotfile(subs, opdir, 'h')
end

return fns
