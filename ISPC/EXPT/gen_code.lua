local ffi = require 'ffi'
local function gen_code(X, T, hash)
  print(type(hash))
  assert(X)
  assert(type(T) == "table")
  local nvals = #T
  assert(nvals > 0)
  local mvals = 16 * math.ceil(nvals / 16.0)
  local sz = mvals * ffi.sizeof("uint64_t")
  local vals = assert(ffi.C.malloc(sz))
  ffi.fill(vals, sz)
  vals = ffi.cast("uint64_t *", vals)
  for k, v in ipairs(T) do
    assert(type(v) == "string")
    vals[k-1]  = hash["fasthash64"](v, #v, X[0].seed)
    -- print(v, h)
  end
  X[0].vals  = vals
  X[0].nvals = nvals
  X[0].mvals = mvals
  return true
end
return gen_code
