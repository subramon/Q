-- STRESS
require 'Q/UTILS/lua/strict'
local plfile = require 'pl.file'
local pldir  = require 'pl.dir'
local qc = require 'Q/UTILS/lua/q_core'
-- This tests whether garbage collection is happening as expected
-- If it were not, this would/should blow through your system's memory
local ffi = require 'Q/UTILS/lua/q_ffi'

local tests = {}

tests.t1 = function()
  for iter = 1, 4 do 
    local X = {}
    for i = 1, 4 do 
      local filename = "./__junk__" .. tostring(i) .. ".bin"
      plfile.write(filename, tostring(i))
      local c_fname = ffi.cast("char*", ffi.malloc(1000))
      ffi.copy(c_fname, filename)
      local mmap = ffi.gc(qc.f_mmap(c_fname, true), qc.f_munmap)
      assert(mmap.status == 0, "Mmap failed")
      X[i] = mmap
    end
    -- local n = collectgarbage("count")
    -- print(" Iter/n ", iter, n)
  end
  local n = collectgarbage("collect")
  assert(n == 0)
  local D = pldir.getfiles("./", "*.bin")
  print(D)
  --TODO: We have removed the file deletion part from f_munmap.c, so is below assert valid?
  assert(#D == 0)
  -- os.execute("rm -f __*.bin")

  print("Test t1 succeeded")
end

return tests
