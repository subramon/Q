--[[ 
A function (that invokes a C function) to perform numerical aggregation of a vector.

Parameters: 
l - library containing aggFn
v - vector to be aggregated e.g. {3,2,5,-1}
elemType - type of vector elements e.g. "int32_t"
aggType - type of aggregation result e.g. "int64_t"
aggFn - name of the C function e.g. "sum"

The C function aggFn should have the signature
int <aggFn>(<elemType> *X, int n, <aggType> *ptr_sum)
--]]
vagg = function (l, v, elemType, aggType, aggFn) 

  local ffi = require("ffi")	--Loading the FFI library
  local decl = "int " .. aggFn .. "(" .. elemType .. " *X, int n, " .. aggType .. " *res);"
  --print("\nCalling "..decl) 
  ffi.cdef(decl)	--Add a C declaration for the C function 
  
  local n = table.getn(v)
 
  local res = ffi.new(aggType .. "[1]"); 
  v = ffi.new(elemType .. "[" .. n .. "]", v) -- create pointer that will be passed to C

  local status = l[aggFn](v, n, res) -- call the C function
  return tonumber(res[0]), status -- tonumber() ensures appropriate conversion to Lua number
end

-- assumes 'dc' is inited
vaggDynCall = function (l, v, elemType, aggType, aggFn) 
  local ffi = require("ffi")	--Loading the FFI library
  
  f = dc.find(l, aggFn)
  dc.mode(dc.C_DEFAULT)
  
  local n = table.getn(v)
  -- create lua object equivalent to ptr_sum
  -- Note that instead of creating a scalar and passing the address of the
  -- scalar to C, we are creating an array of size 1 and passing address of
  -- array to C. This is how we will get C to set the value of a scalar that Lua
  -- can also inspect once set
  local res = ffi.new(aggType .. "[1]"); 
  v = ffi.new(elemType .. "[" .. n .. "]", v) -- create pointer that will be passed to C
  local status = dc.call(f, "pip)i", v, n, res) -- call the C function
  
  return tonumber(res[0]), status -- tonumber() ensures appropriate conversion to Lua number
end