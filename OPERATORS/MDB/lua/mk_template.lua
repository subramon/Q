local ffi = require 'ffi'

ffi.cdef("       void *malloc(size_t size);")
local function mk_template(
  T
  )
  local X = {}
  local CT 
  local idx = {}
  assert(type(T) == "table")
  local nT = #T
  assert(nT > 1)
  local nR = 1
  for k, v in ipairs(T) do 
    nR = nR * (T[k]+1)
  end
  
  --=============================
  local nD = 0
  for k, v in pairs(T) do 
    nD = nD + v
  end
  --=============================
  -- START: Allocate space for C 
  CT = ffi.cast("int **", ffi.C.malloc(nR * ffi.sizeof("int *")))
  for i = 1, nR do 
    CT[i-1] = ffi.cast("int *", ffi.C.malloc(nT * ffi.sizeof("int")))
  end
  --=============================
  local F = {}
  local ctr = 1
  for k, v in pairs(T) do 
    local x = {}
    for i = 1, v do
      x[i]  = ctr
      ctr = ctr + 1
    end
    F[k] = x
  end
  --[[
  -- If T = {3, 4, 2 }, then F = 
F[1] = 
1	1
2	2
3	3
F[2] = 
1	4
2	5
3	6
4	7
F[3] = 
1	8
2	9

  --]]
  --=============================
  local odometer = {}
  for i = 1, nT do 
    odometer[i] = 0
  end
  --=============================
  local rollover = {}
  rollover[nT] = 1
  local idx = nT-1
  repeat 
    rollover[idx] = (T[idx+1]+1) * rollover[idx+1]
    idx = idx - 1
  until idx < 1
  -- for k, v in pairs(rollover) do print(k, v) end
  --=============================
  for k = 1, nR do
    local str = k 
    for i = 1, nT do 
      local x = odometer[i]
      if ( x ~= 0 ) then 
        x = F[i][x]
      end
      str = str .. " " .. x .. " "
      CT[k-1][i-1] = x
    end
    for i = 1, nT do 
      if ( ( k % rollover[i] ) == 0 ) then
        odometer[i] = odometer[i] + 1
        if ( odometer[i] > T[i] ) then odometer[i] = 0 end
      end
    end
    -- print(str)
  end
  return CT, nR, nD, #T
end
return mk_template
--[[ unit test below 
local nDR = {3, 4, 2}
local tmpl, nR, nD, nC = mk_template(nDR)
print("nR, nD, nC = ",  nR, nD, nC )
for j = 1, nR do 
  for i = 1, #nDR do 
    -- print(j-1, tmpl[j-1][i-1])
  end
end
--]]
