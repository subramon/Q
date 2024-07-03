local ffi     = require 'ffi'
local Scalar  = require 'libsclr'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local is_in   = require 'Q/UTILS/lua/is_in'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cutils  = require 'libcutils'
local cmem    = require 'libcmem'

local function vS_specialize(op, invec, in_sclrs, optargs)
  assert(type(op) == "string")
  assert( (op == "vSeq") or  (op == "vSneq" ) )
  local subs = {}
  assert(type(invec) == "lVector")

  subs.qtype = invec:qtype()
  assert(is_in(subs.qtype, 
   { "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8", "F4", "F8", }))
  subs.ctype = cutils.str_qtype_to_str_ctype(subs.qtype)

  assert(invec:has_nulls() == false, "TO BE IMPLEMENTED")
  subs.has_nulls = false

  -- START check in_sclrs 
  local sclrs = {}
  if ( type(in_sclrs) == "number" ) then
    sclrs[#sclrs+1] = assert(Scalar.new(in_sclrs, subs.qtype))
  elseif ( type(in_sclrs) == "table" ) then
    -- all must be scalars or all must be numbers
    assert(#in_sclrs > 0)
    local sclr_type = type(in_sclrs[1])
    for k, v in ipairs(in_sclrs) do 
      assert( ( type(v) == "number") or ( type(v) == "Scalar") )
      assert(type(v) == sclr_type)
    end
    if ( sclr_type == "number" ) then 
      for k, v in ipairs(in_sclrs) do 
        sclrs[k] = assert(Scalar.new(v, subs.qtype))
      end
    else
      for k, v in ipairs(in_sclrs) do 
        assert(v:qtype() == subs.qtype)
      end
      sclrs = in_sclrs
    end
  else
    error("bad scalars type " .. type(in_sclrs))
  end
  -- STOP  sclrs is a table of Scalars of the the right type
  -- Now we convert sclrs into a CMEM
  subs.num_sclrs = #sclrs
  subs.width = invec:width()
  local size = subs.width * #sclrs
  subs.sclr_array = cmem.new({size = size, qtype = subs.qtype})
  local cptr = get_ptr(subs.sclr_array, subs.qtype)
  for k, v in ipairs(sclrs) do 
    local sclr_ptr = ffi.cast(subs.ctype .. " *", v:to_data())
    cptr[k-1] = sclr_ptr[0]
  end
  --====================
  subs.f2_qtype = "BL" -- B1 not supported
  subs.f2_width = 1  
  subs.max_num_in_chunk = invec:max_num_in_chunk()
  subs.f2_bufsz = subs.max_num_in_chunk * subs.f2_width
  --====================
  subs.fn = op .. "_" .. subs.qtype
  subs.tmpl   = "OPERATORS/F1SnOPF2/lua/" .. op .. ".tmpl"
  subs.incdir = "OPERATORS/F1SnOPF2/gen_inc/"
  subs.srcdir = "OPERATORS/F1SnOPF2/gen_src/"
  subs.incs = { "OPERATORS/F1SnOPF2/gen_inc/", "UTILS/inc/" }
  return subs
end
return vS_specialize
