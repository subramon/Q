local gen_code = require "Q/UTILS/lua/gen_code"
local qconsts  = require 'Q/UTILS/lua/q_consts'
local extract_func_decl  = require 'Q/UTILS/lua/extract_func_decl'
local plpath   = require "pl.path"
local srcdir   = "../xgen_src/"
local incdir   = "../xgen_inc/"

local make_get1 = require 'Q/RUNTIME/MAGG/lua/make_get1'
local make_put1 = require 'Q/RUNTIME/MAGG/lua/make_put1'
local make_getn = require 'Q/RUNTIME/MAGG/lua/make_getn'
local make_putn = require 'Q/RUNTIME/MAGG/lua/make_putn'

local make_put1_return = require 'Q/RUNTIME/MAGG/lua/make_put1_return'

local incs 
local function gen_src(
  subs,
  fn,
  only_h
  )
  subs.fn = fn
  local dir = qconsts.Q_SRC_ROOT .. "/RUNTIME/MAGG/lua/" 
  subs.tmpl = dir .. fn .. ".tmpl.lua"
  gen_code.doth(subs, incdir); 
  if ( not only_h ) then 
    gen_code.dotc(subs, srcdir)
  end
end

local function create_dot_o(
  X
  )
  if ( not incs ) then 
    incs = {}
    incs[#incs+1] = "-I../inc/"
    incs[#incs+1] = "-I../../inc/"
    incs[#incs+1] = "-I../xgen_inc/"
    incs[#incs+1] = "-I../../CMEM/inc/"
    incs[#incs+1] = "-I../../SCLR/inc/"
    incs[#incs+1] = "-I../../../UTILS/inc/"
    incs[#incs+1] = " "
    incs = table.concat(incs, " ")
  end
  print("incs = ", incs)
  assert(type(X) == "table")
  for k, v in pairs(X) do 
    local command = "gcc -c "  .. qconsts.QC_FLAGS .. incs .. v
    print("command = ", command)
    status = os.execute(command)
    if ( status ~= 0 ) then print(command) end 
    assert(status == 0)
  end
end


local function libgen(
  T,
  use_lua
  )
  local subs = {}
  if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
  if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
  --=====================================
  assert(type(T) == "table")
  local keytype = assert(T.keytype)
  assert( ( keytype == "I4" ) or ( keytype == "I8" ) ) 
  subs.ckeytype = "u" .. assert(qconsts.qtypes[keytype].ctype)
  --=====================================
  -- lbl is a unique label for each .so file we gernate
  -- if lbl = foobar, then we generate libaggfoobar.so
  local lbl = assert(T.lbl) 
  -- TODO lbl should be generated if not provided
  -- TODO make sure that separate libagg is created for each aggregator
  -- TODO more specifically for each unique params
  local rawlibname = "libagg" .. lbl
  assert(type(lbl) == "string")
  assert(#lbl >= 1 )
  local libname = qconsts.Q_ROOT .. "/lib/libagg" .. lbl .. ".so"
  T.so = "libagg" .. lbl 
  --=====================================
  local vals = assert(T.vals)
  assert(type(vals) == "table")
  local num_vals = #vals
  -- 4 is just an arbitrary but hopefully reasonable limit
  assert( ( num_vals >= 1 ) and ( num_vals <= 4 ) ) 
  subs.num_vals = num_vals
  --=====================================
  local cnttype = "I4"
  if ( T.cnttype ) then 
    assert( (cnttype == "I4" ) or (cnttype == "I8" ) )
  end
  subs.ccnttype = "u" .. assert(qconsts.qtypes[cnttype].ctype)
  --=====================================
  local aggstype  = {}
  local valstype = {}
  local cnt = 0
  for i, v in ipairs(vals) do
    local valtype  = assert(v.valtype)
    assert( ( valtype == "I1" ) or ( valtype == "I2" )  or
            ( valtype == "I4" ) or ( valtype == "I8" )  or
            ( valtype == "F4" ) or ( valtype == "F8" ) ) 
    local aggtype    = assert(v.aggtype)
    --====================
    valstype[i]   = valtype
    aggstype[i]   = aggtype
    --====================
    cnt = cnt + 1
  end
  assert(cnt > 0)
  subs.code_for_update  = "XXXXXX" 
  subs.code_for_promote = "YYYYYY" 
  -- START generating code
  -- set common stuff
  -- notice that key is unsigned
  --================================
  local X = {}
  X[#X+1] = "// start update "
  for i = 1, num_vals do 
    local si = tostring(i)
    local dst = "bkts[probe_loc].val.val_" .. si 
    local src = " val.val_" ..  si 
    if ( aggstype[i] == "set" ) then 
      X[#X+1] = dst .. " = " .. src 
    elseif ( aggstype[i] == "sum" ) then 
      X[#X+1] = dst .. " += " .. src 
    elseif ( aggstype[i] == "cnt" ) then 
      X[#X+1] = dst .. " += 1 " 
    elseif ( aggstype[i] == "min" ) then 
      X[#X+1] = dst .. " = mcr_min(" .. dst .. "," .. src .. ")"
    elseif ( aggstype[i] == "max" ) then 
      X[#X+1] = dst .. " = mcr_max(" .. dst .. "," .. src .. ")"
    else
      assert(nil, "Unknown aggtype = ", aggstype[1])
    end
  end
  X[#X+1] = "// stop update "
  subs.code_for_update = table.concat(X, ";\n");
  --=============================
  local X = {}
  for i = 1, num_vals do 
    local cvaltype = assert(qconsts.qtypes[valstype[i]].ctype)
    X[#X+1] = cvaltype .. " val_" .. tostring(i) .. ";"
  end
  subs.spec_for_vals = table.concat(X, "\n");
  --=============================
  local X = {}
  for i = 1, num_vals do 
    local si = tostring(i)
    X[#X+1] = "if ( v1.val_" .. si .. " != v2.val_" .. si .. " ) { return false; } "
  end
  subs.val_cmp_spec = table.concat(X, "\n");
  --=============================
  -- Following for agg.tmpl.lua
  local dir = qconsts.Q_SRC_ROOT .. "/RUNTIME/MAGG/lua/" 
  subs.tmpl = dir .. 'agg.tmpl.lua'
  subs.lbl = lbl
  subs.fn = "agg"
  subs.qkeytype = keytype

  subs.mk_get1 = make_get1(T)
  subs.mk_put1 = make_put1(T)
  subs.mk_putn = make_putn(T)
  subs.mk_getn = make_getn(T)

  subs.mk_put1_return = make_put1_return(T)

  gen_code.dotc(subs, srcdir)
  --=============================
  gen_src(subs, "hmap_chk_no_holes")
  gen_src(subs, "hmap_del")
  gen_src(subs, "hmap_eq")
  gen_src(subs, "hmap_get")
  gen_src(subs, "hmap_getn")
  gen_src(subs, "hmap_insert")
  gen_src(subs, "hmap_mk_hsh")
  gen_src(subs, "hmap_put")
  gen_src(subs, "hmap_putn")
  gen_src(subs, "hmap_resize")
  gen_src(subs, "hmap_types", true)
  -- identify files from src/ folder and generate .h files for them
  local S = {}
  S[#S+1] = "../src/calc_new_size.c"
  S[#S+1] = "../src/hmap_chk.c"
  S[#S+1] = "../src/hmap_create.c"
  S[#S+1] = "../src/hmap_destroy.c" 
  S[#S+1] = "../src/hmap_instantiate.c"
  S[#S+1] = "../src/hmap_mk_loc.c"
  S[#S+1] = "../src/hmap_mk_tid.c"
  S[#S+1] = "../src/murmurhash.c"
  S[#S+1] = "../src/validate_psl_p.c"
  for k, v in ipairs(S) do 
    extract_func_decl(v, incdir)
  end

  -- compile code 
  local X = {}
  for k, v in ipairs(S) do 
    X[#X+1] = S[k]
  end
  X[#X+1] = srcdir .. "_hmap_chk_no_holes.c" 
  X[#X+1] = srcdir .. "_hmap_del.c" 
  X[#X+1] = srcdir .. "_hmap_eq.c" 
  X[#X+1] = srcdir .. "_hmap_get.c" 
  X[#X+1] = srcdir .. "_hmap_getn.c" 
  X[#X+1] = srcdir .. "_hmap_insert.c" 
  X[#X+1] = srcdir .. "_hmap_mk_hsh.c" 
  X[#X+1] = srcdir .. "_hmap_put.c" 
  X[#X+1] = srcdir .. "_hmap_putn.c" 
  X[#X+1] = srcdir .. "_hmap_resize.c" 
  if ( use_lua ) then 
    X[#X+1] = srcdir .. "_agg.c"
  end
  create_dot_o(X)
  X[#X+1] = " "
  local command = "gcc -shared *.o  " .. qconsts.Q_LINK_FLAGS .. 
    " -o " .. libname
  local status = os.execute(command)
  if ( status ~= 0 ) then print(command) end 
  assert(status == 0)

  return rawlibname 
end
return libgen
