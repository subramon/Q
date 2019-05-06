local qc = require 'Q/UTILS/lua/q_core'
local tests = {}
tests.t1 = function()
  local x = qc.q_omp_get_num_procs()
  assert(x > 0)
end
return tests
