local cutils        = require 'libcutils'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local is_in         = require 'Q/UTILS/lua/is_in'
local good_join_types = { "val", "cnt", "sum", "min", "max", }
return function (
  src_val,
  src_lnk,
  dst_lnk,
  join_types, 
  optargs
  )
  local multi_subs = {} -- table of tables of substiutions
  --===============================================
  assert(type(src_val) == "lVector")
  local sv_qtype = src_val:qtype()
  assert(is_base_qtype(sv_qtype))
  assert(src_val:has_nulls() == false)

  assert(type(src_lnk) == "lVector")
  local sl_qtype = src_lnk:qtype()
  assert(is_base_qtype(sl_qtype))
  assert(src_val:has_nulls() == false)

  assert(type(dst_lnk) == "lVector")
  local dl_qtype = dst_lnk:qtype()
  assert(is_base_qtype(dl_qtype))
  assert(dst_lnk:has_nulls() == false)

  assert(src_val:max_num_in_chunk() == src_lnk:max_num_in_chunk())
  assert(src_val:max_num_in_chunk() == dst_lnk:max_num_in_chunk())
  assert(sl_qtype == dl_qtype)

  -- TODO P1 Check that src_lnk and dst_lnk are sorted ascending 

  if ( optargs ) then assert(type(optargs) == "table") end -- not used now
  --===============================================
  assert(type(join_types) == "table")
  assert(#join_types >= 1)
  for k, join_type in ipairs(join_types) do 
    assert(is_in(join_type, good_join_types))
  end
  --===============================================
  for k, join_type in ipairs(join_types) do 
    local subs = {}
    local T = {}
    T[#T+1] = "join"
    T[#T+1] = join_type
    T[#T+1] = sv_qtype
    T[#T+1] = sl_qtype
    subs.fn = table.concat(T, "_")

    --=========================================================
    local dv_qtype
    if ( ( join_type == "val" ) or ( join_type == "min" ) or 
         ( join_type == "max" ) ) then
      dv_qtype = sv_qtype
    elseif ( join_type == "sum" ) then 
      if ( is_int_qtype(sv_qtype) ) then 
        dv_qtype = "I8"
      else
        dv_qtype = "F8"
      end
    elseif ( join_type == "cnt" ) then 
      dv_qtype = "I8"
    else
      error("bad join_type")
    end

    subs.max_num_in_chunk = src_val:max_num_in_chunk()

    subs.src_val_qtype = sv_qtype
    subs.src_val_ctype = cutils.str_qtype_to_str_ctype(subs.src_val_qtype)
    subs.src_val_cast_as = subs.src_val_ctype .. " *"
    subs.src_val_width = cutils.get_width_qtype(subs.src_val_qtype)
    subs.src_val_bufsz = subs.src_val_width * subs.max_num_in_chunk
  
    subs.src_lnk_qtype = sl_qtype
    subs.src_lnk_ctype = cutils.str_qtype_to_str_ctype(subs.src_lnk_qtype)
    subs.src_lnk_cast_as = subs.src_lnk_ctype .. " *"
    subs.src_lnk_width = cutils.get_width_qtype(subs.src_lnk_qtype)
    subs.src_lnk_bufsz = subs.src_lnk_width * subs.max_num_in_chunk
  
    subs.dst_val_qtype = dv_qtype
    subs.dst_val_ctype = cutils.str_qtype_to_str_ctype(subs.dst_val_qtype)
    subs.dst_val_cast_as = subs.dst_val_ctype .. " *"
    subs.dst_val_width = cutils.get_width_qtype(subs.dst_val_qtype)
    subs.dst_val_bufsz = subs.dst_val_width * subs.max_num_in_chunk
    subs.nn_dst_val_bufsz = 1 * subs.max_num_in_chunk
  
    -- NOTE separate template for each join type 
    subs.tmpl   = "OPERATORS/JOIN/lua/join_" .. join_type.. ".tmpl"
    subs.incdir = "OPERATORS/JOIN/gen_inc/"
    subs.srcdir = "OPERATORS/JOIN/gen_src/"
    subs.incs   = { "UTILS/inc", "OPERATORS/JOIN/gen_inc/" }
  
    multi_subs[join_type] = subs
  end
  return multi_subs
end
