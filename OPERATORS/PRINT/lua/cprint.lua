local function min(x, y) if x < y then return x else return y end 
local function max(x, y) if x > y then return x else return y end 
local chunk_num = math.floor(lb / chunk_size)
local nC = #V
C = assert(cmem.new(nC * ffi.sizeof("void *")))
C = ffi.cast("void **", C)
while true do 
  clb = chunk_num * chunk_size
  cub = clb + chunk_size
  assert(clb >= ub) -- TODO verify boundary conditions
  if ( cub >= lb ) then break end-- TODO verify boundary conditions
  local xlb = max(lb, clb)
  local xub = min(ub, cub)
  local nR
  local wchunk, wlen, W
  if ( where ) then 
    wlen, wchunk = where:get_chunk(chunk_num)
    assert(wlen > 0)
    W = ffi.cast("uint64_t *", get_ptr(wchunk))
  end
  local C = {}
  for i, v in ipairs(V) do
    if ( i == 1 ) then nR = len else assert(nR == len) end 
    local len, chnk = v:get_chunk(chunk_num)
    assert(len > 0)
    C[i] = ffi.cast("void *", get_ptr(chnk))
  end
  if ( wlen ) then assert(len == wlen) end 
  status = qc.cprint(opfile, W, C, nC, xlb -lb, xub - xlb, fldtypes)
end
