local cutils = require 'libcutils'
local do_subs       = require 'Q/UTILS/lua/do_subs' 
local gen_code      = require 'Q/UTILS/lua/gen_code' 
local simple_do_subs       = 
  require 'Q/TMPL_FIX_HASHMAP/KEY_COUNTER/lua/simple_do_subs'
local gen_rsx_types = 
  require 'Q/TMPL_FIX_HASHMAP/KEY_COUNTER/lua/gen_rsx_types'
local copy_generic_code  = 
  require 'Q/TMPL_FIX_HASHMAP/KEY_COUNTER/lua/copy_generic_code'
local copy_specific_code = 
  require 'Q/TMPL_FIX_HASHMAP/KEY_COUNTER/lua/copy_specific_code'
local exec_and_capture_stdout = 
  require 'Q/UTILS/lua/exec_and_capture_stdout'

--=================================
local function mk_dir(x)
  assert(type(x) == "string")
  assert(not cutils.isdir(x), "directory exists " .. x)
  assert(cutils.makepath(x))
  assert(cutils.isdir(x))
  return true
end
  --=========================
  -- make key counter .so file and function declarations needed for cdef
local function make_kc_so(configs)
  assert(type(configs) == "table")
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
  local cdef_str = {} -- string containing declarations to be cdef'd
  --= Make sure output directories are okay
  local q_src_root = assert(os.getenv("Q_SRC_ROOT"), "Q_SRC_ROOT not set")
  local tmpl_dir = q_src_root .. "/TMPL_FIX_HASHMAP/"
  assert(cutils.isdir(tmpl_dir))
  local root_dir = q_src_root .. "/TMPL_FIX_HASHMAP/KEY_COUNTER/" .. label
  local src_dir = root_dir .. "/src/"
  local inc_dir = root_dir .. "/inc/"
  assert(mk_dir(root_dir))
  assert(mk_dir(src_dir))
  assert(mk_dir(inc_dir))
  -- add structs from rs_hmap_config to stuff to be cdef'd
  -- NOT Done here. Done in KeyCounter.lua
  -- local f = tmpl_dir .. "/inc/rs_hmap_config.h"
  -- cdef_str[#cdef_str+1] = cutils.read(f)
  --=== make rsx_types.h
  local f = inc_dir .. "/rsx_types.h"
  local x = gen_rsx_types(configs)
  assert(cutils.write(f, x))
  assert(cutils.isfile(f))
  cdef_str[#cdef_str+1] = cutils.read(f)
  --=== make rs_hmap_struct.h
  local outfile = inc_dir .. "/rs_hmap_struct.h"
  local infile  = q_src_root .. "/TMPL_FIX_HASHMAP/inc/rs_hmap_struct.h"
  simple_do_subs(configs.label, infile, outfile)
  -- Ideally, we should not need altfile, relic of old convention
  -- But until we change it systematically, it stays
  local altfile  = inc_dir .. "/" .. label .. "_rs_hmap_struct.h"
  cutils.copyfile(outfile, altfile) 
  cdef_str[#cdef_str+1] = cutils.read(outfile)
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
  -- need to call instantiate from Lua code 
  local outfile  = inc_dir .. "/_rs_hmap_instantiate.h"
  cdef_str[#cdef_str+1] = cutils.read(outfile)
  -- need to call destroy from Lua code 
  local outfile  = inc_dir .. "/_rs_hmap_destroy.h"
  cdef_str[#cdef_str+1] = cutils.read(outfile)
  -- IDeally, following should have been handled in template code
  -- i.e., we need custom names for rs_hmap_destroy otherwise
  -- we get conflicts when we cdef 
  local incfile  = inc_dir .. "/_rs_hmap_destroy.h"
  local instr = cutils.read(outfile)
  local generic_name = "rs_hmap_destroy%("
  local custom_name = label .. "_rs_hmap_destroy%("
  local outstr = string.gsub(instr, generic_name, custom_name)
  assert(cutils.write(incfile, outstr))
  
  local srcfile  = src_dir .. "/_rs_hmap_destroy.c"
  local instr = cutils.read(srcfile)
  local generic_name = "rs_hmap_destroy%("
  local custom_name = label .. "_rs_hmap_destroy%("
  local outstr = string.gsub(instr, generic_name, custom_name)
  assert(cutils.write(srcfile, outstr))
  --=========== make copies of all specific code
  local F2 = { 
    "key_cmp",
    "set_hash",
    "val_update",
  }
  local specific_dir = q_src_root .. "/TMPL_FIX_HASHMAP/KEY_COUNTER/src/"
  local prefix = "rsx_"
  copy_specific_code(configs.label, prefix, specific_dir, root_dir, F2)
  -- START: create rsx_put 
  local subs = {}
  subs.label = label
  -- NOTE: Assumptiion that no more that 4 keys in compound key 
  local n = #configs.key_types 
  if ( n >= 1 ) then subs.comment1 = "  " else subs.comment1 = "//" end
  if ( n >= 2 ) then subs.comment2 = "  " else subs.comment2 = "//" end
  if ( n >= 3 ) then subs.comment3 = "  " else subs.comment3 = "//" end
  if ( n >= 4 ) then subs.comment4 = "  " else subs.comment4 = "//" end
  if ( n >= 5 ) then error(" no more that 4 keys in compound key ") end 
  subs.fn = label  .. "_rsx_kc_put"
  subs.tmpl = q_src_root .. 
     "/TMPL_FIX_HASHMAP/KEY_COUNTER/src/rsx_kc_put.tmpl.lua"
  local src_file = gen_code.dotc(subs, src_dir)
  local inc_file = gen_code.doth(subs, inc_dir)
  cdef_str[#cdef_str+1] = cutils.read(inc_file)
  -- STOP : create rsx_put 
  -- START: create rsx_make_permutation 
  local subs = {}
  subs.label = label
  -- NOTE: Assumptiion that no more that 4 keys in compound key 
  local n = #configs.key_types 
  if ( n >= 1 ) then subs.comment1 = "  " else subs.comment1 = "//" end
  if ( n >= 2 ) then subs.comment2 = "  " else subs.comment2 = "//" end
  if ( n >= 3 ) then subs.comment3 = "  " else subs.comment3 = "//" end
  if ( n >= 4 ) then subs.comment4 = "  " else subs.comment4 = "//" end
  if ( n >= 5 ) then error(" no more that 4 keys in compound key ") end 
  subs.fn = label  .. "_rsx_kc_make_permutation"
  subs.tmpl = q_src_root .. 
     "/TMPL_FIX_HASHMAP/KEY_COUNTER/src/rsx_kc_make_permutation.tmpl.lua"
  local src_file = gen_code.dotc(subs, src_dir)
  local inc_file = gen_code.doth(subs, inc_dir)
  cdef_str[#cdef_str+1] = cutils.read(inc_file)
  -- STOP : create rsx_make_permutation 
  -- START: create rsx_cum_count 
  local subs = {}
  subs.label = label
  subs.fn = label  .. "_rsx_kc_cum_count"
  subs.tmpl = q_src_root .. 
     "/TMPL_FIX_HASHMAP/KEY_COUNTER/src/rsx_kc_cum_count.tmpl.lua"
  local src_file = gen_code.dotc(subs, src_dir)
  local inc_file = gen_code.doth(subs, inc_dir)
  cdef_str[#cdef_str+1] = cutils.read(inc_file)
  -- STOP : create rsx_cum_count 
  
  -- create INCS to specify directories for include 
  local X = {}
  X[#X+1] = "-I" .. inc_dir
  X[#X+1] = "-I" .. tmpl_dir .. "/inc/"
  X[#X+1] = "-I" .. q_src_root .. "/UTILS/inc/" 
  local INCS = table.concat(X, " ")
  -- print("====="); print(INCS); print("=====")
  -- create list of files to be compiled
  local X = {}
  for _, f in ipairs(F) do
    X[#X+1] = src_dir .. "/_rs_hmap_" .. f .. ".c" 
    assert(cutils.isfile(X[#X]))
  end
  for _, f in ipairs(F2) do
    X[#X+1] = src_dir .. "/_rsx_" .. f .. ".c" 
    assert(cutils.isfile(X[#X]), "File not found " .. X[#X])
  end
  X[#X+1] = src_dir .. "/" .. label .. "_rsx_kc_put.c" 
  X[#X+1] = src_dir .. "/" .. label .. "_rsx_kc_cum_count.c" 
  X[#X+1] = src_dir .. "/" .. label .. "_rsx_kc_make_permutation.c" 
  local SRCS = table.concat(X, " ")
  -- print(SRCS); print("=====")
  --=================================
  local QCFLAGS = assert(os.getenv("QCFLAGS"), "QCFLAGS not set")
  local cmd = {}
  cmd[#cmd+1] = "gcc -shared"
  cmd[#cmd+1] = QCFLAGS
  cmd[#cmd+1] = INCS
  cmd[#cmd+1] = SRCS
  local  sodir = assert(os.getenv("Q_ROOT")) .. "/lib/"
  assert(cutils.isdir(sodir), "Directory not found " .. sodir)
  local sofile = sodir .. "libkc" .. label .. ".so"
  cmd[#cmd+1] = " -o " .. sofile 
  cmd = table.concat(cmd, " ")
  -- print(cmd)
  local rslt = exec_and_capture_stdout(cmd)
  assert(cutils.isfile(sofile))
  -- ready to return stuff
  cdef_str = table.concat(cdef_str, "\n")
  -- START Ugly: following is a bit ugly but can be improved later TODO P3
  local tmpf1 = cutils.mkstemp("/tmp/_Q_XXXXXX")
  local tmpf2 = cutils.mkstemp("/tmp/_Q_XXXXXX")
  assert(cutils.write(tmpf1, cdef_str))
  local cmd = 'grep -v "^#include " ' .. tmpf1  .. " | " ..
    ' grep -v "^#define " | grep -v "^#ifndef " | grep -v "^#endif" > ' 
    .. tmpf2
  local rslt = exec_and_capture_stdout(cmd)
  local cdef_str = cutils.read(tmpf2)
  cutils.delete(tmpf1)
  cutils.delete(tmpf2)
  assert(#cdef_str > 0)
  -- STOP  Ugly
  -- print("Code gen complete")
  return sofile, cdef_str
end
return make_kc_so
