--local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'lua/q_ffi'
local qc      = require 'lua/q_core'

local chunk_size = 64 * 1024
local Vector = {}
Vector.__index = Vector

setmetatable(Vector, {
        __call = function (cls, ...)
            return cls.new(...)
        end,
    })

function Vector.new(arg)
  local vec = setmetatable({}, Vector)
  vec._vec = ffi.malloc(ffi.sizeof("VEC_REC_TYPE"), qc.vec_free)
  vec._vec = ffi.cast("VEC_REC_TYPE *", vec._vec)
  qc.vec_new(vec._vec, arg.field_size, chunk_size)
  print("Created vec")
  return vec
end

function Vector:set(addr, len)
  addr = ffi.cast("char *", addr)
  qc.vec_set(self._vec, addr, len)
end

return Vector
