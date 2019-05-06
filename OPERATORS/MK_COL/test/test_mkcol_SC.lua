local plfile = require 'pl.file'
local Q = require 'Q'
local tmpfile = "/tmp/_xxx"

local tests = {}
tests.t1 = function()
  local x = Q.mk_col({"abc", "defg", "hijkl"}, "SC")
  Q.print_csv(x, { opfile = tmpfile } )
  local y = plfile.read(tmpfile)
  z = [[
abc
defg
hijkl
]]
  assert(y == z)
  assert(x:field_width() == 6)
  plfile.delete(tmpfile)
end
return tests
