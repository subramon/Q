local file_exists = require 'Q/UTILS/lua/file_exists'

local section = { c = 'definition', h = 'declaration' }

local function do_replacements(tmpl, subs)
  local T
  if ( file_exists(tmpl) ) then 
    T = assert(dofile(tmpl))
  else 
    assert(nil)
    --[[ TODO P1 Is it okay to comment this out?
    local filename = q_tmpl_dir .. tmpl
    assert(qc.isfile(filename), "File not found " .. filename)
    T = dofile(filename)
    --]]
  end
   for k,v in pairs(subs) do
      T[k] = v
   end
   return T
end


local _dotfile = function(subs, tmpl, opdir, ext)
  local T = do_replacements(tmpl, subs)
  local dotfile = T(section[ext])

  if ( ( not opdir ) or ( opdir == "" ) ) then
    return dotfile
  end
  assert( ( opdir )  and ( type(opdir) == "string" ) ) 
  --TODO P1 local fname = opdir .. "/_" .. subs.fn .. "." .. ext, "w"
  local fname = opdir .. "/_" .. subs.fn .. "." .. ext
  local f = assert(io.open(fname, "w"))
  assert(f, "Unable to open file " .. fname)
  f:write(dotfile)
  f:close()
  return true
end

local fns = {}

fns.dotc = function (subs, tmpl, opdir)
  return _dotfile(subs, tmpl, opdir, 'c')
end

fns.doth = function (subs, tmpl, opdir)
  return _dotfile(subs, tmpl, opdir, 'h')
end

return fns
