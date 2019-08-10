local Q          = require 'Q'
local Scalar     = require 'libsclr'
local cmem       = require 'libcmem'
local ffi = require 'ffi'
local qconsts    = require 'Q/UTILS/lua/q_consts'
local chk_params = require 'Q/ML/KNN/lua/chk_params'
local plfile     = require 'pl.file' -- TEMPORARY
local get_ptr    = require 'Q/UTILS/lua/get_ptr'

local hdr = plfile.read("../inc/calc_vote_per_g.h")
ffi.cdef(hdr)
local libc = ffi.load("../src/calc_vote_per_g.so")

--=======================================
local function mk_ptrs(T, m, name, ctype)
  assert(type(T) == "table")
  assert(m > 0)
  local sz = m * ffi.sizeof(ctype .. "*")
  -- TODO: P2 Using CMEM below causes a crash. Why?
  local c_T = ffi.gc(ffi.C.malloc(sz), ffi.C.free)
  c_T = ffi.cast(ctype .. "** ", c_T)
  i = 0
  for attr, vec in pairs(T) do
    local a, x_chunk, b = vec:get_all()
    c_T[i] = ffi.cast(ctype .. " *",  get_ptr(x_chunk))
    i = i + 1
  end
  return c_T
end
--=======================================
local function chk_data(T)
  assert(type(T) == "table")
  local m = 0
  local n 
  for k, v in pairs(T) do 
    assert(type(v) == "lVector")
    assert(v:fldtype() == "F4")
    if ( m == 0 ) then
      n = v:length()
      assert(n > 0)
    else
      assert(n == v:length())
    end
    m = m + 1 
  end
  assert(m > 0)
  return m, n
end
--=======================================
local function chk_params(
    T_train, 
    T_test
    )
  local m_train, n_train = chk_data(T_train)
  local m_test,  n_test  = chk_data(T_test)
  return m_train, n_train, n_test
end
--=======================================
local function voting_custom_code(
  T_train, -- table of m lVectors of length n_train
  m,
  n_train,
  T_test, -- table of m lVectors of length n_test
  n_test,
  output, -- lVector of length n_test
  is_chk_params
  )
  if ( is_chk_params == nil ) then is_chk_params = true end 
  assert(type(is_chk_params) == "boolean")
  -- Some assumptions made to expedite programming. Undo them. TODO P3
  if ( is_chk_params ) then 
    assert(type(T_train) == "table")
  end
  local qtype = output:fldtype()
  assert(qtype == "F4")
  local ctype  = qconsts.qtypes[qtype].ctype
  --===========================================

  local _, c_output, _ = output:start_write()
  c_output= ffi.cast(ctype .. " *",  get_ptr(c_output))

  c_train = mk_ptrs(T_train, m, "train", ctype)
  c_test  = mk_ptrs(T_test, m, "test", ctype)
  libc.calc_vote_per_g(
    c_train, m, n_train, c_test, n_test, c_output)
  output:end_write()
end
return voting_custom_code
