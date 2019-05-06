print('Hi')

--[[
local c = terralib.includec("stdio.h")
for k,v in pairs(c) do
    print(k)
end
--]]

local add = function (typ1, typ2, typ3)
  return terra(a: typ1, b: typ2, r: typ3, sz: int)
    for i=0,sz do
      @(r+i) = @(a+i) + @(b+i)
    end
    return 0;
  end
end

local arrPrinter = function (typ)
  return terra (a: &typ, sz:int)
    for i=0,sz do
      print(a[i])
    end
  end
end

local arrElemSetter = function(typ)
  return terra (a: &typ, i: int, v: typ)
    @(a+i)=v
  end
end

C = terralib.includec("stdlib.h")

function Array(typ)
    return terra(N : int)
        var r : &typ = [&typ](C.malloc(sizeof(typ) * N))
        return r
    end
end

-- I've called the param as "ctype" to relate to our existing terminology
-- ctype is the Terra-primitive-type object (*not* a string)
initArr = function(ctype, a, sz, t)
  -- set array elems (similar approach can be used for str-to-typ conversions)
  for k,v in pairs(t) do
    arrElemSetter(ctype)(a, k-1, v)
  end
end

Array = terralib.memoize(Array)
arrElemSetter = terralib.memoize(arrElemSetter)
arrPrinter = terralib.memoize(arrPrinter)
add = terralib.memoize(add)

-- Two approaches for type-based dispatch of add
-- Approach 1: incrementally create your own lib at runtime
-- Approach 2: use memoized functions directly like "add"

-- INIT for approach 1
mylib = {}
mylib["add_uint8_uint8_uint16"] = add(&uint8, &uint8, &uint16)
-- END INIT for approach 1

-- init the arrays
local arr1, arr2, res = Array(uint8)(3), Array(uint8)(3), Array(uint16)(3)
initArr(uint8, arr1, 3, {1,2,3})
initArr(uint8, arr2, 3, {4,5,6})

-- check array contents (similar approach can be used for typ-to-str conversions)
arrPrinter(uint8)(arr1, 3)
-- arrPrinter(uint8)(arr2, 3)

-- Invoke add by Approach 1
mylib["add_uint8_uint8_uint16"](arr1, arr2, res, 3)
-- arrPrinter(uint16)(res, 3)

-- Invoke add by Approach 2
add(&uint8, &uint8, &uint16)(arr1, arr2, res, 3)
-- arrPrinter(uint16)(res, 3)
