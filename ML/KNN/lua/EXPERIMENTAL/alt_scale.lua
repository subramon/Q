local Q = require 'Q'
local Scalar = require 'libsclr'
local cmem = require 'libcmem'
local ffi = require 'ffi'
local chk_params = require 'Q/ML/KNN/lua/chk_params'
local plfile = require 'pl.file' -- TEMPORARY
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local hdr = plfile.read("../inc/calc_scale.h")
ffi.cdef(hdr)
local libc = ffi.load("../src/calc_vote_per_g.so")

--=======================================
local function mk_ptrs(T, m)
  assert(m > 0)
  local sz = m * ffi.sizeof("float *")
  -- TODO: P2 Using CMEM below causes a crash. Why?
  local c_T = ffi.gc(ffi.C.malloc(sz), ffi.C.free)
  c_T = ffi.cast("float ** ", c_T)
  i = 0
  for attr, vec in pairs(T) do
    local a, x_chunk, b = vec:get_all()
    local x = ffi.cast("float *",  get_ptr(x_chunk))
    c_T[i] = x
    i = i + 1
  end
  return c_T
end
--=======================================
local function alt_scale(
  T, -- table of m lVectors of length n_train
  m,
  n
  )
  
  c_data  = mk_ptrs(T, m)
  libc.calc_scale(c_data, m, n)
end
return alt_scale
