local plfile = require 'pl.file'
local plpath = require 'pl.path'
local qconsts = require 'Q/UTILS/lua/q_consts'
local src_dir = "../x_gen_src/"
local inc_dir = "../x_gen_inc/"
plpath.rmdir(src_dir)
plpath.rmdir(inc_dir)
plpath.mkdir(src_dir)
plpath.mkdir(inc_dir)
assert(plpath.isdir(src_dir))
assert(plpath.isdir(inc_dir))

local function substitute(
  subs,
  infile,
  outfile,
  genfiles
  )
  assert(type(subs) == "table")
  assert(plpath.isfile(infile))
  assert(type(outfile) == "string")
  if ( genfiles ) then assert(type(genfiles) == "table") end 
  --=======================================
  local str = plfile.read(infile)
  for k, v in pairs(subs) do 
    str = string.gsub(str, k, v)
  end
  --=======================================
  plfile.write(outfile, str)
  if ( genfiles ) then
    genfiles[#genfiles+1] = outfile
  end 
  return true
end


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
    local subs  = {}
    local infile 
    local outfile
    --================================================
    subs.__KEYTYPE__ = keyctype
    subs.__VALTYPE__ = valctype
    subs.__K__       = key
    subs.__KV__      = kv
    outfile = inc_dir ..  "_q_rhashmap_" .. key .. "_" .. val .. ".h"
    infile = "q_rhashmap.tmpl.h"
    substitute(subs, infile, outfile, hfiles)
    --================================================
    infile = "q_rhashmap_struct.tmpl.h"
    outfile = "_q_rhashmap_struct_" .. key .. "_" .. val .. ".h"
    substitute(subs, infile, outfile, hfiles)
    --================================================
    infile  = "q_rhashmap_struct.tmpl.h"
    outfile = "_q_rhashmap_struct_" .. key .. "_" .. val .. ".h"
    substitute(subs, infile, outfile, hfiles)
    --================================================
    infile = "q_rhashmap.tmpl.c"
    outfile = "_q_rhashmap_" .. key .. "_" .. val .. ".c"
    substitute(subs, infile, outfile, cfiles)
    --================================================
  end
end
for _, key in pairs(keytypes) do 
    --================================================
    local keyctype = qconsts.qtypes[key].ctype
    local subs  = {}
    local infile 
    local outfile
    subs.__KEYTYPE__ = keyctype
    subs.__K__       = key
    --================================================
    infile = "q_rhashmap_mk_hash.tmpl.c"
    outfile = "_q_rhashmap_mk_hash_" .. key .. ".c"
    substitute(subs, infile, outfile, cfiles)
    --================================================
    infile = "q_rhashmap_mk_hash.tmpl.h"
    outfile = "_q_rhashmap_mk_hash_" .. key .. ".h"
    substitute(subs, infile, outfile, hfiles)
    --================================================
end
print(table.concat(cfiles, ' '))
-- print out the .h files into file _files_to_include.h
local prtbl = {}
for _, v in ipairs(hfiles) do 
  prtbl[#prtbl+1] = "#include \"" .. v .. "\""
end
prtbl[#prtbl+1] = "\n"
plfile.write("_files_to_include.h", table.concat(prtbl, '\n'))
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
