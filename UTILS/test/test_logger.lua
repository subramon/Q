l = require 'Q/UTILS/lua/logger'
local tests = {}
tests.debug = function()
  assert( l.new({outfile = "t"}):debug('hey') == true) 
  return true
end

tests.warn = function()
  print('hello')
  print(l.new({outfile = "t", level="warn"}):debug('hey')) 
  print('bye')
  assert( l.new({outfile = "t", level="warn"}):debug('hey') == false)
  return true
end

return tests
