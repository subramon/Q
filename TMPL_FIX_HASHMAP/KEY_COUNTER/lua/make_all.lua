local plfile        = require 'pl.file'
local plpath        = require 'pl.path'
local do_subs       = require 'do_subs'
local gen_rsx_types = require 'gen_rsx_types'
local copy_generic_code  = require 'copy_generic_code'
local copy_specific_code = require 'copy_specific_code'
local exec_and_capture_stdout = require 'exec_and_capture_stdout'

assert(type(arg) == "table")
local config_file = assert(arg[1], "config file not provided")
assert(plpath.exists(config_file))
local x = loadfile(config_file)
assert(type(x) == "function")
local configs = x()
assert(type(configs) == "table")
--=================================
local function mk_dir(x)
  assert(type(x) == "string")
  assert(not plpath.isdir(x), "directory exists " .. x)
  assert(plpath.mkdir(x))
  assert(plpath.isdir(x))
  return true
end
--=========================
-- Check label is okay 
local ok_chars = 
 "abcdefghijklmnopqrstuvwxyz" ..
 "ABCDEFGHIJKLMNOPQRSTUVWXYZ" ..
 "0123456789_"
local label = configs.label
assert(type(label) == "string")
for i = 1, #label do 
  local c = string.sub(label, i, i)
  local n1, n2 = string.find(ok_chars, c)
  assert(type(n1) == "number")
  assert(n1 >= 1)
end 
--= Make sure output directories are okay
local q_src_root = assert(os.getenv("Q_SRC_ROOT"))
local tmpl_dir = q_src_root .. "/TMPL_FIX_HASHMAP/"
assert(plpath.isdir(tmpl_dir))
local root_dir = q_src_root .. "/TMPL_FIX_HASHMAP/KEY_COUNTER/" .. label
local src_dir = root_dir .. "/src/"
local inc_dir = root_dir .. "/inc/"
assert(mk_dir(root_dir))
assert(mk_dir(src_dir))
assert(mk_dir(inc_dir))
--=== make rsx_types.h
local f = inc_dir .. "/rsx_types.h"
local x = gen_rsx_types(configs)
plfile.write(f, x)
--=== make rs_hmap_struct.h
local outfile = inc_dir .. "/rs_hmap_struct.h"
local infile  = q_src_root .. "/TMPL_FIX_HASHMAP/inc/rs_hmap_struct.h"
do_subs(configs.label, infile, outfile)
-- Ideally, we should not need altfile, relic of old convention
-- But until we change it systematically, it stays
local altfile  = inc_dir .. "/" .. label .. "_rs_hmap_struct.h"
plfile.copy(outfile, altfile) 
print("Made " .. altfile)
-- ==== make copies of all common code 
local F = {
"chk", 
"del", 
"destroy", 
"freeze", 
"get", 
"insert", 
"set_fn_ptrs", 
"merge", 
"pr", 
"put", 
"resize", 
"row_dmp", 
"unfreeze", 
"instantiate", 
}

copy_generic_code(configs.label, tmpl_dir, root_dir, F)
--=========== make copies of all specific code
local F2 = { 
  "key_cmp",
  "set_hash",
}
local specific_dir = q_src_root .. "/TMPL_FIX_HASHMAP/KEY_COUNTER/src/"
local prefix = "rsx_"
copy_specific_code(configs.label, prefix, specific_dir, root_dir, F2)
-- create INCS to specify directories for include 
local X = {}
X[#X+1] = "-I" .. inc_dir
X[#X+1] = "-I" .. tmpl_dir .. "/inc/"
X[#X+1] = "-I" .. q_src_root .. "/UTILS/inc/" 
local INCS = table.concat(X, " ")
-- print(INCS); print("=====")
-- create list of files to be compiled
local X = {}
for _, f in ipairs(F) do
  X[#X+1] = src_dir .. "/_rs_hmap_" .. f .. ".c" 
  assert(plpath.isfile(X[#X]))
end
for _, f in ipairs(F2) do
  X[#X+1] = src_dir .. "/_rsx_" .. f .. ".c" 
  assert(plpath.isfile(X[#X]))
end
local SRCS = table.concat(X, " ")
-- print(SRCS); print("=====")
--=================================
local QCFLAGS = assert(os.getenv("QCFLAGS"))
local cmd = {}
cmd[#cmd+1] = "gcc -shared"
cmd[#cmd+1] = QCFLAGS
cmd[#cmd+1] = INCS
cmd[#cmd+1] = SRCS
local sofile = "libkc" .. label .. ".so"
cmd[#cmd+1] = " -o " .. sofile 
cmd = table.concat(cmd, " ")
print(cmd)
local rslt = exec_and_capture_stdout(cmd)
assert(plpath.isfile(sofile))
print("Code gen complete")

