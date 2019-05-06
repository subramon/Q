--[[ qcbnd exposes 2 public functions
loadlib : set the library to be used, takes parameter as path to library

cdecl : C function name, C return type, ..<C parameter types>..
  "Declares" the C function, and returns a function which when called with actual parameters, will invoke the C function.
  The returned function 
    - ensures translation of actual parameters to C before invoking C function
    - pass parameter "out" if it's an out-param; corresponding value will be returned from the lua function call as additional results after the value returned from C function
--]]
qcbnd = {}

qcbnd.loadlib = function (s)
  qcbnd.lib = require("ffi").load(s)
end

qcbnd.ptdeclToAct = function (s)
    local len = string.len(s)
    if string.sub(s, len, len) == "*" then
      -- http://lua-users.org/wiki/CommonFunctions
      return string.sub(s:gsub("^%s*(.-)%s*$", "%1"), 1, len-1)
    else
      return s
    end
end

qcbnd.cdecl = function(fname, rtyp, ...) -- TODO memoize
  local ffi = require("ffi")
  local decl = rtyp .. " " .. fname .. "("
  
  local n = select("#",...)
  local ptdecl = {}
  local ptact = {}
  for i=1, n-1 do
    ptdecl[i] = (select(i,...))
    decl = decl .. ptdecl[i] .. ","
    ptact[i] = qcbnd.ptdeclToAct(ptdecl[i])
  end
  ptdecl[n] = (select(n,...))
  decl = decl .. ptdecl[n]  .. ");"
  ptact[n] = qcbnd.ptdeclToAct(ptdecl[n])
  ffi.cdef(decl) 
  
  -- TODO varargs in C function are TBD
  return function(...)
    print ("calling... " .. decl)
    local p = {}
    local np = select("#",...)
    local outs = {}
    for i=1, np do
      local pi = (select(i, ...))
      if (type (pi) == "table") then
        p[i] = ffi.new (ptact[i] .. "[" .. table.getn(pi) .. "]", pi)
      elseif (pi == "out") then
        p[i] = ffi.new(ptact[i] .. "[1]"); 
        outs[table.getn(outs) + 1] = i
      else  
        p[i] = pi        
      end
    end
    local res = {}
    res[1] = qcbnd.lib[fname](unpack(p))
    
    for i=1, table.getn(outs) do
      -- TODO not numbers??!!
      res[i+1] = tonumber(p[outs[i]][0])
    end
    return unpack(res)
  end
end

-------- TEST CASE ----------

-- set library to be used
qcbnd.loadlib("/home/srinath/Ramesh/qfork/Q/experimental/SUM/adder.so")

-- declare C function and get handle to invoke it
local f = qcbnd.cdecl("int32_sum", "int32_t", "int32_t *", "int", "int32_t *")

-- call C function; last param is out-parameter to C; will get returned as "sum"
local status, sum = f({1,2,1}, 3, "out")
print("\n--------------")
print(status)
print(sum)
