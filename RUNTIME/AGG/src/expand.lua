local plfile = require 'pl.file'
local qconsts = require 'Q/UTILS/lua/q_consts'


local keytypes = { "I4", "I8" }
local valtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
local cmd = [[
hfile=q_rhashmap.h;
cfile=q_rhashmap.c;
cp $hfile _
]]

cfiles = {}
hfiles = {}
tbl = {}
for _, key in pairs(keytypes) do 
  for _, val in pairs(valtypes) do 
    local hstr = plfile.read("q_rhashmap.h")
    local keyctype = qconsts.qtypes[key].ctype
    local valctype = qconsts.qtypes[val].ctype
    local kv = key .. "_" .. val
    hstr = string.gsub(hstr, "__KEYTYPE__", keyctype);
    hstr = string.gsub(hstr, "__VALTYPE__", valctype);
    hstr = string.gsub(hstr, "__KV__", kv);
    local outh = "_q_rhashmap_" .. key .. "_" .. val .. ".h"
    plfile.write(outh, hstr)
    hfiles[#hfiles+1] = '#include "' .. outh .. '"'

    local cstr = plfile.read("q_rhashmap.c")
    cstr = string.gsub(cstr, "__KV__", kv);
    cstr = string.gsub(cstr, "__KEYTYPE__", keyctype);
    cstr = string.gsub(cstr, "__VALTYPE__", valctype);
    local outc = "_q_rhashmap_" .. key .. "_" .. val .. ".c"
    plfile.write(outc, cstr)
    cfiles[#cfiles+1] = outc
  end
end
print(table.concat(cfiles, ' '))

hfiles[#hfiles+1] = "\n"
plfile.write("_files_to_include.h", table.concat(hfiles, '\n'))
--======================================
instr = [[
  else if ( ( strcmp(keytype, "KEY") == 0 ) &&  ( strcmp(valtype, "VAL") == 0 ) ) {
    x = (void *)q_rhashmap_create_KEY_VAL(initial_size);
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
    tbl[#tbl+1] = str
  end
end
tbl[#tbl+1] = "\n"
plfile.write("_creation.c", table.concat(tbl, '\n'))
--======================================
instr = [[
  else if ( ( strcmp(ptr_key->field_type, "KEY") == 0 ) && 
       ( strcmp(ptr_val->field_type, "VAL") == 0 ) ) {
    q_rhashmap_put_KEY_VAL((q_rhashmap_KEY_VAL_t *)ptr_agg->hmap,
    ptr_key->cdata.valKEY, ptr_key->cdata.valVAL);
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
    tbl[#tbl+1] = str
  end
end
tbl[#tbl+1] = "\n"
plfile.write("_put.c", table.concat(tbl, '\n'))
--======================================
