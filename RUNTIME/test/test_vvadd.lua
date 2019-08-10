local qconsts = require 'Q/UTILS/lua/q_consts'
local cmem    = require 'libcmem' 
local ffi = require 'ffi'
local lVector = require 'Q/RUNTIME/lua/lVector'
local Scalar  = require 'libsclr'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local prcsv   = require "Q/OPERATORS/PRINT/lua/print_csv"

local tests = {}

local function vvadd(
  v1, 
  v2
  )
  assert(type(v1) == "lVector")
  assert(type(v2) == "lVector")
  local n     = v1:length()
  local qtype = v1:fldtype()
  local w     = qconsts.qtypes[qtype].width
  assert(v2:length() == n)
  assert(v2:fldtype() == qtype)
  local v3  = lVector({gen = true, qtype = qtype, has_nulls = false})
  local b3  = cmem.new(n*w, qtype, "buffer")
  local cd3 = get_ptr(b3, qtype) -- get data pointer

  local cidx = 0
  repeat
    local n1, d1 = v1:chunk(cidx)
    local n2, d2 = v2:chunk(cidx)
    assert(n1 == n2)
    assert( ( (d1 == nil) and (d2 == nil) )  or 
            ( (d1 ~= nil) and (d2 ~= nil) ) )

    if ( n1 == 0 ) then break end 
    local cd1 = get_ptr(d1, qtype)
    local cd2 = get_ptr(d2, qtype)
    for i = 0, n1 do 
      cd3[i] = cd1[i] + cd2[i]
    end
    v3:put_chunk(b3, nil, n1)
    cidx = cidx + 1
  until false
  v3:eov()
  return v3
end
tests.t1 = function(
  qtype,
  n
  )
  local qtype = qtype or "I4"
  local n     = n or qconsts.chunk_size
  local v     = lVector({gen = true, qtype = qtype, has_nulls = false})
  local w     = qconsts.qtypes[qtype].width
  local b     = cmem.new(n*w, "I4", "buffer")
  local dptr  = get_ptr(b, "I4") -- get data pointer
  for i = 0, n-1 do 
    dptr[i] = i+1
  end
  v:put_chunk(b, nil, n)
  v:eov()
  print("Completed test t1")
  return v

end

tests.t2 = function(
  qtype,
  n
  )
  local qtype = qtype or "I4"
  local n     = n or 2*qconsts.chunk_size+1
  local v1 = tests.t1(qtype, n)
  local v2 = tests.t1(qtype, n)
  local v3 = vvadd(v1, v2)
  assert(type(v3) == "lVector")
  -- prcsv(v2, { opfile = "/tmp/_v2.csv" })
  --==================
  local s3 = v3:get_one(0)
  local s2 = v2:get_one(0)
  assert(s3 == Scalar.new(2, "I4") * s2)
  --==================
  local s3 = v3:get_one(n-1)
  local s2 = v2:get_one(n-1)
  assert(s3 == Scalar.new(2, "I4") * s2)

  print("Completed test t2")
end

return tests
