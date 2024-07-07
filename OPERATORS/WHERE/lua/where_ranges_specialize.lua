local cutils        = require 'libcutils'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local lVector       = require 'Q/RUNTIME/VCTR/lua/lVector'

return function (invec, ranges, optargs)
  local subs = {}; 
  assert(type(invec) == "lVector")
  subs.in_qtype = invec:qtype()
  assert(is_base_qtype(subs.in_qtype))

  subs.max_num_in_chunk = invec:max_num_in_chunk()
  assert(not invec:has_nulls()) -- TODO P4 For later 

  subs.out_qtype = subs.in_qtype
  subs.out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)
  subs.out_width = cutils.get_width_qtype(subs.out_qtype)
  subs.cast_out_as = subs.out_ctype .. " *"
  subs.bufsz = subs.out_width * subs.max_num_in_chunk

  assert(type(ranges) == "tbl")
  assert(#ranges > 0)
  for k, range in ipairs(ranges) do 
    assert(type(range) == "table")
    assert(#range == 2)
    local lb = range[1]
    local ub = range[2]
    assert(lb >= 0)
    assert(ub > lb)
    -- upper bound of next range must be >= lb of this range
    if ( k < #ranges ) then 
      local next_range = ranges[k+1]
      assert(next_range[1] >= range[2])
    end
  end
  --=====================================================
  -- Convert Lua ranges to C ranges
  local nR = #ranges
  local clb = ffi.new("uint64_t[?]", nR)
  local cub = ffi.new("uint64_t[?]", nR)
  for k, range in ipairs(ranges) do 
    clb[k-1] = range[1]
    cub[k-1] = range[2]
  end
  subs.clb = clb
  subs.cub = cub
  --=====================================================

  subs.fn      = "where_range_" .. subs.in_qtype
  subs.tmpl    = "OPERATORS/WHERE/lua/where_ranges" .. subs.in_qtype
  subs.srcdir  = "OPERATORS/WHERE/gen_src/"
  subs.incdir  = "OPERATORS/WHERE/gen_inc/"
  subs.incs    = { "OPERATORS/WHERE/gen_inc/", "UTILS/inc/" }


  return subs
end
