local Dictionary    = require 'Q/UTILS/lua/dictionary'
local ffi           = require 'Q/UTILS/lua/q_ffi'
local lVector       = require 'Q/RUNTIME/lua/lVector'
local qc            = require 'Q/UTILS/lua/q_core'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local cmem          = require 'libcmem'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'

local function load_csv_fast_C(
  M, 
  infile, 
  file_offset,
  is_hdr)
  assert( M and type(M) == "table")
  assert(infile and type(infile) == "string")
  assert(is_hdr and type(is_hdr) == "boolean")

  local nR = ffi.cast("uint64_t *", get_ptr(cmem.new(1*ffi.sizeof("uint64_t"))))
  nR[0] = 0
  local nC = #M

  local fldtypes = get_ptr(cmem.new(nC * ffi.sizeof("char *")))
  fldtypes = ffi.cast("char **", fldtypes)
  
  -- TODO Deal with fld_sep
  local is_load = get_ptr(cmem.new(nC * ffi.sizeof("bool")))
  is_load = ffi.cast("bool *", is_load)

  local has_nulls = get_ptr(cmem.new(nC * ffi.sizeof("bool")))
  has_nulls = ffi.cast("bool *", has_nulls)  
  
  local num_nulls = get_ptr(cmem.new(nC * ffi.sizeof("uint64_t")))
  num_nulls = ffi.cast("uint64_t *", num_nulls)
  local fld_name_width = 4 -- TODO Undo this hard coiding
  for i = 1, nC do
    fldtypes[i-1]  = ffi.cast("char *", get_ptr(cmem.new(fld_name_width * ffi.sizeof("char"))))
    ffi.copy(fldtypes[i-1], M[i].qtype)
    is_load[i-1]   = M[i].is_load
    has_nulls[i-1] = M[i].has_nulls
  end

  local out_files = nil
  local nil_files = nil 

  local sz_str_for_lua = qconsts.sz_str_for_lua

  local str_for_lua = cmem.new(sz_str_for_lua * ffi.sizeof("char"))
  str_for_lua:zero()
  str_for_lua = ffi.cast("char *", get_ptr(str_for_lua))

  local n_str_for_lua = get_ptr(cmem.new(1 * ffi.sizeof("int32_t")))
  n_str_for_lua = ffi.cast("int *", n_str_for_lua)
  n_str_for_lua[0] = 0

  assert(qc["isdir"](data_dir))
  assert(qc["isfile"](infile))

  -- assert(nil, "premature") -- call to the load_csv_fast function
  local status = qc["load_csv_fast"](data_dir, infile, nC, nR, fldtypes,
  is_hdr, is_load, has_nulls, num_nulls, out_files, nil_files,
  str_for_lua, sz_str_for_lua, n_str_for_lua);
  -- assert(nil, "Premature termination")
  assert(status == 0, "load_csv_fast failed")

  local n = n_str_for_lua[0]
  assert(n > 0)
  local str_to_load = ffi.string(str_for_lua, n)
  local T = loadstring(str_to_load)()
  assert(T)
  assert( (type(T) == "table" ), "type of T is not table")
  for i = 1, #T do
    assert( type(T[i]) == "lVector", "type is not lVector")
  end
  
  return T
end

return load_csv_fast_C

