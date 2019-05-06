local plpath = require 'pl.path'

local section = { c = 'definition', h = 'declaration' }

local q_tmpl_dir = os.getenv("Q_TMPL_DIR") .. "/"
assert(plpath.isdir(q_tmpl_dir))
local function do_replacements(tmpl, subs)
  local T
  if ( plpath.isfile(tmpl) ) then 
    T = assert(dofile(tmpl))
  else 
    local filename = q_tmpl_dir .. tmpl
    assert(plpath.isfile(filename))
    T = dofile(filename)
  end
   for k,v in pairs(subs) do
      T[k] = v
   end
   return T
end


local _dotfile = function(subs, tmpl, opdir, ext)
  local T = do_replacements(tmpl, subs)
  local orig_ext = ext
  -- CUDA: Did a little hack here, as I was not getting the file contents from T when provided the ext='cu'
  -- CUDA: So temporarily provided the ext as 'c' and retrieved the file contents
  if ext == "cu" then ext = "c" end
  local dotfile = T(section[ext])

  if ( ( not opdir ) or ( opdir == "" ) ) then
    return dotfile
  end
  assert(plpath.isdir(opdir), "Unable to find opdir " .. opdir)
  local fname = opdir .. "_" .. subs.fn .. "." .. orig_ext, "w"
  local f = assert(io.open(fname, "w"))
  f:write(dotfile)
  f:close()
  return true
end

local fns = {}

-- CUDA: Introduced optional argument 'ext'
fns.dotc = function (subs, tmpl, opdir, ext)
  if not ext then ext = 'c' end
  return _dotfile(subs, tmpl, opdir, ext)
end

fns.doth = function (subs, tmpl, opdir)
  return _dotfile(subs, tmpl, opdir, 'h')
end

return fns
