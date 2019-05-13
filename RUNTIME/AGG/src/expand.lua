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
    local outc = "_q_rhashmap_" .. key .. "_" .. val .. ".c"
    plfile.write(outc, cstr)
    cfiles[#cfiles+1] = outc
  end
end
hfiles[#hfiles+1] = "\n"
print(table.concat(cfiles, ' '))
plfile.write("_files_to_include.h", table.concat(hfiles, '\n'))
