local Q = require 'Q'
require 'Q/UTILS/lua/strict'
describe("Column should not evaluate on chunk(-1)", function()
  local x = Q.const({ val = 1, len = 1025, qtype = 'F8' })
  local y = Q.const({ val = 1, len = 1025, qtype = 'F8' })
  it("sizeof chunk -1 should be 0 when no eval done", function()

  local sz, xc, nxc = x:chunk(-1)
  assert.True(sz == 0 )
  assert.True(xc == nil )
  assert.True(nxc == nil )

  local sz, xc, nxc = y:chunk(-1)
  assert.True(sz == 0 )
  assert.True(xc == nil )
  assert.True(nxc == nil )
  end)
  
  print("Successfully completed in " .. arg[0])
end)
