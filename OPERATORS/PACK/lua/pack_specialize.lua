local cutils  = require 'libcutils'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local is_in   = require 'Q/UTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'

local function pack_specialize(vec_tbl, out_qtype)
  local subs = {}
  assert(type(vec_tbl) == "table")
  for k, v in ipairs(vec_tbl) do 
    assert(type(v) == "lVector")
  end
  assert(type(out_qtype) == "string")
  assert(is_in(out_qtype, { "UI2", "UI4", "UI8", "UI16", }))
  subs.out_qtype = out_qtype
  subs.out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)
  subs.out_width = cutils.get_width_qtype(subs.out_qtype)

  local sum_in_width = 0
  local nC = 0
  for k, v in ipairs(vec_tbl) do 
    sum_in_width = sum_in_width + v:width()
    if ( k == 1 ) then 
      nC = v:max_num_in_chunk() 
    else
      assert(nC == v:max_num_in_chunk())
    end 
  end
  assert(sum_in_width <= subs.out_width)
  subs.max_num_in_chunk = nC
  subs.bufsz = subs.max_num_in_chunk * subs.out_width
  --======================================================
  subs.n_vals = #vec_tbl
  subs.width = cmem.new({size = ffi.sizeof("uint32_t") * subs.n_vals,
    qtype = "UI4"})
  local width_ptr = get_ptr(subs.width, "UI4")
  for k, v in ipairs(vec_tbl) do 
    width_ptr[k-1] = v:width()
  end

  -- cols is meant to hold pointers to chunks of each vector in vec_tbl
  subs.cols = cmem.new(ffi.sizeof("char *") * subs.n_vals)

  subs.fn = "pack_" .. out_qtype
  subs.tmpl   = "OPERATORS/PACK/lua/pack.tmpl"
  subs.incdir = "OPERATORS/PACK/gen_inc/"
  subs.srcdir = "OPERATORS/PACK/gen_src/"
  subs.incs = { "OPERATORS/PACK/gen_inc/" }

  return subs
end
return pack_specialize
