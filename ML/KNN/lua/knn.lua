local Q = require 'Q'

local function knn(
  T, -- table of m Vectors of length n
  g, -- Vector of length n
  x, -- Lua table of m Scalars
  k -- number of neighbors we care about
  )
  local n = g:length()
  local m = #T
  local d = Q.const({val = 0, qtype = "F4", len = n})
  for i = 1, m do -- for each dimension
    d = Q.vvadd(d, Q.sqr(Q.vssub(T[i], x[i])))
  end
  return Q.mink_reducer(d, g, k)
end

return knn
