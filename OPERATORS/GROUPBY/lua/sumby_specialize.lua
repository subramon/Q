local cutils = require 'libcutils'
local is_in = require 'Q/UTILS/lua/is_in'
local get_max_num_in_chunk = require 'Q/UTILS/lua/get_max_num_in_chunk'
local val_qtypes = { 'I1', 'I2', 'I4', 'I8', 'F4', 'F8' }
local grp_qtypes = { 'I1', 'I2', 'I4', 'I8' }

return function (
  val_fld, -- value to be aggregated
  grp_fld, -- group by column
  nb, -- => range of values in grp_fld = 0 .. nb-1 
  cnd_fld, -- condition field 
  optargs
  )
  local subs = {}
  assert(type(nb) == "number")
  assert(nb > 1)

  subs.max_num_in_chunk = get_max_num_in_chunk(optargs)
  assert(nb <= subs.max_num_in_chunk) -- TODO P3 Relax this assumption
  --==============================================
  assert(type(val_fld) == "lVector")
  assert(val_fld:has_nulls() == false)
  subs.val_qtype = val_fld:qtype()
  assert(is_in(subs.val_qtype, val_qtypes))
  subs.val_ctype = cutils.str_qtype_to_str_ctype(subs.val_qtype)
  subs.cast_val_fld_as = subs.val_ctype .. " *"

  --==============================================
  assert(type(grp_fld) == "lVector")
  assert(grp_fld:has_nulls() == false)
  subs.grp_qtype = grp_fld:qtype()
  assert(is_in(subs.grp_qtype, grp_qtypes))
  subs.grp_ctype = cutils.str_qtype_to_str_ctype(subs.grp_qtype)
  subs.cast_grp_fld_as = subs.grp_ctype .. " *"

  --==============================================
  if ( ( subs.val_qtype == "F4" ) or ( subs.val_qtype == "F8" ) ) then 
    subs.out_val_qtype = "F8"
  else
    subs.out_val_qtype = "I8"
  end
  subs.out_val_ctype = cutils.str_qtype_to_str_ctype(subs.out_val_qtype)
  subs.cast_out_val_as = subs.out_val_ctype .. " *"

  subs.out_cnt_qtype = "I8"
  subs.out_cnt_ctype = cutils.str_qtype_to_str_ctype(subs.out_cnt_qtype)
  subs.cast_out_cnt_as = subs.out_cnt_ctype .. " *"

  -- I think it is okay to alloacte nb and not max_num_in_chunk
  -- This needs to be verified  TODO P3 
  subs.out_val_buf_size = 
    subs.max_num_in_chunk * cutils.get_width_qtype( subs.out_val_qtype)
  subs.out_cnt_buf_size = 
    subs.max_num_in_chunk * cutils.get_width_qtype( subs.out_cnt_qtype)

  --==============================================
  subs.is_safe = true 
  if ( optargs ) then
    assert(type(optargs) == "table")
    if ( optargs.is_safe ) then 
      subs.is_safe = optargs.is_safe 
    end
  end
  assert(type(subs.is_safe) == "boolean")
  --==============================================

  if ( cnd_fld ) then 
    assert(type(cnd_fld) == "lVector")
    assert(cnd_fld:has_nulls() == false)
    assert(cnd_fld:qtype() == "BL") -- TODO P4 Implement "B1" 
    subs.cnd_qtype = cnd_fld:qtype()
    subs.cnd_ctype = cutils.str_qtype_to_str_ctype(subs.cnd_qtype)
    subs.cast_cnd_fld_as = subs.cnd_ctype .. " *"
  end
  if ( subs.is_safe ) then 
    subs.checking_code = 
      "    if ( ( x < 0 ) || ( x >= (int)nR_out ) ) { go_BYE(-1); } "
    subs.bye = "BYE: "
  else
    subs.checking_code = ""
    subs.bye = ""
  end
  subs.operating_code = "out_val_fld[x] += val_fld[i]; "
  --=======================
  subs.fn = "sumby_" .. subs.val_qtype .. "_" ..subs.grp_qtype 
  if ( subs.is_safe ) then 
    subs.fn = subs.fn .. "_safe" 
  end
  if ( cnd_fld )  then 
    subs.fn = subs.fn .. "_where_" .. subs.cnd_qtype
  end
  --=======================
  subs.tmpl = "OPERATORS/GROUPBY/lua/sumby.tmpl"
  subs.srcdir = "OPERATORS/GROUPBY/gen_src/"
  subs.incdir = "OPERATORS/GROUPBY/gen_inc/"
  subs.incs   = { "OPERATORS/GROUPBY/gen_inc/", "UTILS/inc/", }
  return subs
end
