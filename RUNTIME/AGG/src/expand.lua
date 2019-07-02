local plfile = require 'pl.file'
local plpath = require 'pl.path'
local qconsts = require 'Q/UTILS/lua/q_consts'
local src_dir = "../gen_src/"
local inc_dir = "../gen_inc/"
plpath.rmdir(src_dir)
plpath.rmdir(inc_dir)
plpath.mkdir(src_dir)
plpath.mkdir(inc_dir)
assert(plpath.isdir(src_dir))
assert(plpath.isdir(inc_dir))


--======================================
local keytypes = { "I4", "I8" }
local valtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }

cfiles = {}
hfiles = {}
tbl = {}
for _, key in pairs(keytypes) do 
  for _, val in pairs(valtypes) do 
    --================================================
    local keyctype = qconsts.qtypes[key].ctype
    local valctype = qconsts.qtypes[val].ctype
    local kv = key .. "_" .. val
    local hstr, cstr
    --================================================
    hstr = plfile.read("q_rhashmap.tmpl.h")
    hstr = string.gsub(hstr, "__KEYTYPE__", keyctype);
    hstr = string.gsub(hstr, "__VALTYPE__", valctype);
    hstr = string.gsub(hstr, "__K__", key);
    hstr = string.gsub(hstr, "__KV__", kv);
    local outh = "_q_rhashmap_" .. key .. "_" .. val .. ".h"
    plfile.write(inc_dir .. outh, hstr)
    hfiles[#hfiles+1] = '#include "' .. outh .. '"'
    --================================================
    hstr = plfile.read("q_rhashmap_struct.tmpl.h")
    hstr = string.gsub(hstr, "__KEYTYPE__", keyctype);
    hstr = string.gsub(hstr, "__VALTYPE__", valctype);
    hstr = string.gsub(hstr, "__KV__", kv);
    local outh = "_q_rhashmap_struct_" .. key .. "_" .. val .. ".h"
    plfile.write(inc_dir .. outh, hstr)
    --================================================
    cstr = plfile.read("q_rhashmap.tmpl.c")
    cstr = string.gsub(cstr, "__KEYTYPE__", keyctype);
    cstr = string.gsub(cstr, "__VALTYPE__", valctype);
    hstr = string.gsub(hstr, "__K__", key);
    cstr = string.gsub(cstr, "__KV__", kv);
    local outc = "_q_rhashmap_" .. key .. "_" .. val .. ".c"
    plfile.write(src_dir .. outc, cstr)
    cfiles[#cfiles+1] = src_dir .. outc
    --================================================
  end
end
for _, key in pairs(keytypes) do 
    --================================================
    local keyctype = qconsts.qtypes[key].ctype
    local hstr, cstr
    --================================================
    cstr = plfile.read("q_rhashmap_mk_hash.tmpl.c")
    cstr = string.gsub(cstr, "__KEYTYPE__", keyctype);
    cstr = string.gsub(cstr, "__K__", key);
    local outc = "_q_rhashmap_mk_hash_" .. key .. ".c"
    plfile.write(src_dir .. outc, cstr)
    cfiles[#cfiles+1] = src_dir .. outc
    --================================================
    hstr = plfile.read("q_rhashmap_mk_hash.tmpl.h")
    hstr = string.gsub(hstr, "__KEYTYPE__", keyctype);
    hstr = string.gsub(hstr, "__K__", key);
    local outh = "_q_rhashmap_mk_hash_" .. key .. ".h"
    plfile.write(inc_dir .. outh, hstr)
    hfiles[#hfiles+1] = '#include "' .. outh .. '"'
    --================================================
end
print(table.concat(cfiles, ' '))

hfiles[#hfiles+1] = "\n"
plfile.write("_files_to_include.h", table.concat(hfiles, '\n'))
-- The following files are created with a .x suffix. They are not
-- really stand-alone files but are included
--======================================
instr = [[
  else if ( ( strcmp(keytype, "KEY") == 0 ) &&  ( strcmp(valtype, "VAL") == 0 ) ) {
    x = (q_rhashmap___KV___t *)q_rhashmap_create___KV__(initial_size);
  }
  ]]
tbl = {}
local first = true
for _, key in pairs(keytypes) do 
  for _, val in pairs(valtypes) do 
    local kv = key .. "_" .. val
    local str = instr
    if ( first ) then
      str = string.gsub(str, "else if", "if")
      first = false
    end
    str = string.gsub(str, "KEY", key)
    str = string.gsub(str, "VAL", val)
    str = string.gsub(str, "__KV__", kv);
    tbl[#tbl+1] = str
  end
end
tbl[#tbl+1] = "\n"
plfile.write(src_dir .. "_creation.x", table.concat(tbl, '\n'))
--======================================
instr = [[
  else if ( ( strcmp(ptr_key->field_type, "KEY") == 0 ) && 
       ( strcmp(ptr_val->field_type, "VAL") == 0 ) ) {
    status = q_rhashmap_put_KEY_VAL(
      (q_rhashmap_KEY_VAL_t *)ptr_agg->hmap,
      ptr_key->cdata.valKEY, 
      ptr_val->cdata.valVAL,
      update_type,
      (VCTYPE *)ptr_oldval,
      &num_probes
      );
  }
  ]]
tbl = {}
local first = true
for _, key in pairs(keytypes) do 
  for _, val in pairs(valtypes) do 
    local str = instr
    if ( first ) then
      str = string.gsub(str, "else if", "if")
      first = false
    end
    str = string.gsub(str, "KEY", key)
    str = string.gsub(str, "VAL", val)
    str = string.gsub(str, "VCTYPE", qconsts.qtypes[val].ctype)
    tbl[#tbl+1] = str
  end
end
tbl[#tbl+1] = "\n"
plfile.write(src_dir .. "_put1.x", table.concat(tbl, '\n'))
--======================================
instr= [[
  else if ( ( strcmp(ptr_key->field_type, "KEY") == 0 ) && 
       ( strcmp(valqtype, "VAL") == 0 ) ) {
    status = q_rhashmap_get_KEY_VAL(
      (q_rhashmap_KEY_VAL_t *)ptr_agg->hmap,
      ptr_key->cdata.valKEY, 
      (VCTYPE *)ptr_oldval,
      ptr_is_found
      );
  }
]]
tbl = {}
local first = true
for _, key in pairs(keytypes) do 
  for _, val in pairs(valtypes) do 
    local str = instr
    if ( first ) then
      str = string.gsub(str, "else if", "if")
      first = false
    end
    str = string.gsub(str, "KEY", key)
    str = string.gsub(str, "VAL", val)
    str = string.gsub(str, "VCTYPE", qconsts.qtypes[val].ctype)
    tbl[#tbl+1] = str
  end
end
tbl[#tbl+1] = "\n"
assert(#tbl > 10)
plfile.write(src_dir .. "_get1.x", table.concat(tbl, '\n'))
--======================================
-- Produce del1 - similar to get1
instr = plfile.read(src_dir .. "_get1.x")
instr = string.gsub(instr, "_get_", "_del_");
plfile.write(src_dir .. "_del1.x", instr)
--======================================
-- Produce *destroy.c
instr= [[
  else if ( ( strcmp(ptr_agg->keytype, "KEY") == 0 ) &&  ( strcmp(ptr_agg->valtype, "VAL") == 0 ) ) {
    q_rhashmap_destroy___KV__(ptr_agg->hmap);
  }
]]
tbl = {}
local first = true
for _, key in pairs(keytypes) do 
  for _, val in pairs(valtypes) do 
    local kv = key .. "_" .. val
    local str = instr
    if ( first ) then
      str = string.gsub(str, "else if", "if")
      first = false
    end
    str = string.gsub(str, "KEY", key)
    str = string.gsub(str, "VAL", val)
    str = string.gsub(str, "__KV__", kv);
    tbl[#tbl+1] = str
  end
end
tbl[#tbl+1] = "\n"
plfile.write(src_dir .. "_destroy.x", table.concat(tbl, '\n'))
--======================================
instr = [[
  else if ( ( strcmp(keys->field_type, "KEY") == 0 ) && 
      ( strcmp(vals->field_type, "VAL") == 0 ) ) {
    status = q_rhashmap_putn_KEY_VAL( (q_rhashmap_KEY_VAL_t *)ptr_agg->hmap,  
    update_type, (KCTYPE *)keys->data, hashes, locs, tids,
    nT, (VCTYPE *)vals->data, nkeys, isfs);
  }
  ]]
tbl = {}
local first = true
for _, key in pairs(keytypes) do 
  for _, val in pairs(valtypes) do 
    local str = instr
    if ( first ) then
      str = string.gsub(str, "else if", "if")
      first = false
    end
    str = string.gsub(str, "KEY", key)
    str = string.gsub(str, "VAL", val)
    str = string.gsub(str, "VCTYPE", qconsts.qtypes[val].ctype)
    str = string.gsub(str, "KCTYPE", qconsts.qtypes[key].ctype)
    tbl[#tbl+1] = str
  end
end
tbl[#tbl+1] = "\n"
plfile.write(src_dir .. "_putn.x", table.concat(tbl, '\n'))
--======================================
instr = [[
  else if ( ( strcmp(keys->field_type, "KEY") == 0 ) && 
      ( strcmp(vals->field_type, "VAL") == 0 ) ) {
    status = q_rhashmap_getn_KEY_VAL( 
    (q_rhashmap_KEY_VAL_t *)ptr_agg->hmap,  
    (KCTYPE *)keys->data, hashes, locs, (VCTYPE *)vals->data, nkeys);
  }
  ]]
tbl = {}
local first = true
for _, key in pairs(keytypes) do 
  for _, val in pairs(valtypes) do 
    local str = instr
    if ( first ) then
      str = string.gsub(str, "else if", "if")
      first = false
    end
    str = string.gsub(str, "KEY", key)
    str = string.gsub(str, "VAL", val)
    str = string.gsub(str, "VCTYPE", qconsts.qtypes[val].ctype)
    str = string.gsub(str, "KCTYPE", qconsts.qtypes[key].ctype)
    tbl[#tbl+1] = str
  end
end
tbl[#tbl+1] = "\n"
plfile.write(src_dir .. "_getn.x", table.concat(tbl, '\n'))
--======================================
