local file_exists = require 'Q/UTILS/lua/file_exists'

local section = { c = 'definition', h = 'declaration' }

local function do_replacements(subs)
  local tmpl = subs.tmpl
  local T
  assert(file_exists(tmpl), "File not found " .. tmpl)
  T = assert(dofile(tmpl))
  for k, v in pairs(subs) do
     T[k] = v
  end
  return T
end


local _dotfile = function(subs, opdir, ext)
  if ( ( ext == "c" ) and ( subs.dotc ) ) then 
    -- This is to catch an old  but discontinued convention
    -- TODO P3 Delete when no longer needed
    error("WHY WOULD WE CALL gen_code when we have .c file")
    return subs.dotc 
  end
  if ( ( ext == "h" ) and ( subs.doth ) ) then 
    -- This is to catch an old  but discontinued convention
    -- TODO P3 Delete when no longer needed
    error("WHY WOULD WE CALL gen_code when we have .h file")
    return subs.doth 
  end
  local T = do_replacements(subs)
  local dotfile = T(section[ext])

  if ( ( not opdir ) or ( opdir == "" ) ) then
    return dotfile
  end
  assert( ( opdir )  and ( type(opdir) == "string" ) ) 
  local fname = opdir .. "/_" .. subs.fn .. "." .. ext
  local f = assert(io.open(fname, "w"))
  assert(f, "Unable to open file " .. fname)
  f:write(dotfile)
  f:close()
  return true
end

local fns = {}

fns.dotc = function (subs, opdir)
  return _dotfile(subs, opdir, 'c')
end

fns.doth = function (subs, opdir)
  return _dotfile(subs, opdir, 'h')
end

return fns
