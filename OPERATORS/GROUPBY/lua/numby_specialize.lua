local cutils = require 'libcutils'
local is_in     = require 'Q/UTILS/lua/is_in'
local in_qtypes = { 'I1', 'I2', 'I4', 'I8', 'UI1', 'UI2', 'UI4', 'UI8', }
local get_max_num_in_chunk = require 'Q/UTILS/lua/get_max_num_in_chunk'

return function (
  val_fld,  -- value to be aggregated
  nb, -- range of values is 0 .. nb-1
  cnd_fld, -- optional condition field 
  optargs
  )
  local subs = {};

  assert(type(val_fld) == "lVector")
  assert(val_fld:has_nulls() == false)
  subs.val_qtype = val_fld:qtype()
  assert(is_in(subs.val_qtype, in_qtypes))

  if ( cnd_fld ) then 
    assert(type(cnd_fld) == "lVector")
    assert(cnd_fld:has_nulls() == false)
    assert(cnd_fld:qtype() == "BL" ) -- B1 not supported yet 
    subs.cnd_qtype = cnd_fld:qtype()
  end

  --========================================
  if ( type(nb) == "Scalar") then nb = nb:to_num() end 
  assert(type(nb) == "number")
  assert(nb >= 1 )
  subs.nb = nb 
  --========================================
  -- default for max_num_in_chunk
  local y = math.floor(nb / 64)
  if ( ( y * 64 ) ~= nb ) then y = y + 1 end 
  subs.max_num_in_chunk = y * 64
  -- over-ride max_num_in_chunk if needed
  if optargs then
    assert(type(optargs) == "table")
    if ( optargs.max_num_in_chunk ) then  
      local x = optargs.max_num_in_chunk
      assert(type(x) == "number")
      assert(x >= 64 )
      assert( (math.floor(x / 64 ) *64) == x)
      assert(nb <= x)
      subs.max_num_in_chunk = x
    end
  end
  --========================================
  -- Keeping default is_safe value as true
  -- This will not allow C code to write values at incorrect locations
  subs.is_safe = true
  if optargs then
    assert(type(optargs) == "table")
    if ( optargs.is_safe ~= nil ) then
      assert(type(opargs.is_safe) == "boolean")
      subs.is_safe = optargs.is_safe
    end
  end
  --========================================

  subs.val_ctype = cutils.str_qtype_to_str_ctype(subs.val_qtype)
  subs.cast_val_as = subs.val_ctype .. " *"

  subs.cnd_ctype = "bool"
  subs.cast_cnd_as = "bool *"

  subs.out_qtype = "I8"
  subs.out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)
  subs.cast_out_as = subs.out_ctype .. " *"
  subs.out_width = cutils.get_width_qtype(subs.out_qtype)
  subs.out_buf_size = subs.out_width * subs.max_num_in_chunk

  subs.fn = "numby_" .. subs.val_qtype 
  if ( subs.is_safe == false ) then subs.fn = subs.fn .. "_unsafe" end

  if ( subs.is_safe ) then 
    subs.checking_code = 
    " if ( ( x < 0 ) || ( (uint32_t)x >= nZ ) ) { go_BYE(-1); } "
    subs.bye = "BYE: "
  else
    subs.fn = subs.fn .. "_unsafe" 
    subs.checking_code = " /* No checks made on value */ "
    subs.bye = " "
  end
  subs.tmpl   = "OPERATORS/GROUPBY/lua/numby.tmpl"
  subs.srcdir = "OPERATORS/GROUPBY/gen_src/"
  subs.incdir = "OPERATORS/GROUPBY/gen_inc/"
  subs.incs   = { "OPERATORS/GROUPBY/gen_inc/", "UTILS/inc/" }
  return subs
end
