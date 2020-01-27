local qconsts = require 'Q/UTILS/lua/q_consts'

local Q_ROOT      = qconsts.Q_ROOT 

local assertx  = require 'Q/UTILS/lua/assertx'
local compile  = require 'Q/UTILS/lua/compile'
local ffi      = require 'ffi'
local gen_code = require 'Q/UTILS/lua/gen_code'
local qconsts  = require 'Q/UTILS/lua/q_consts'

--=== From runtime
local cutils  = require 'libcutils'
local cmem    = require 'libcmem'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local Dnn     = require 'libdnn'
--==================
local sofile   = Q_ROOT .. "/lib/libq_core.so"
local incfile  = Q_ROOT .. "/include/q_core.h"
local inc_dir  = Q_ROOT .. "/include/"
local lib_dir  = Q_ROOT .. "/lib/"

-- START: Put in a bunch of cdefs that we will need later
-- TODO P1 Do we still need FILE? 
ffi.cdef([[
typedef struct {
   char *fpos;
   void *base;
   unsigned short handle;
   short flags;
   short unget;
   unsigned long alloc;
   unsigned short buffincrement;
} FILE;
  struct drand48_data
  {
    unsigned short int __x[3];	/* Current state.  */
    unsigned short int __old_x[3]; /* Old state.  */
    unsigned short int __c;	/* Additive const. in congruential formula.  */
    unsigned short int __init;	/* Flag for initializing.  */
    __extension__ unsigned long long int __a;	/* Factor in congruential
						   formula.  */
  };
   ]])
   -- Note that struct tm done in q_consts.lua
   --[[
   --NOTE: I gave a name TM to the struct tm because LuaFFI complained
--]]

-- STOP: Put in a bunch of cdefs that we will need later

-- The first thing we do is to make sure that we can access functionality
-- provided by C from Lua. This assumes that 2 files have been created
-- incfile, typically $HOME/local/Q/include/q_core.h
-- sofile,  typically $HOME/local/Q/lib/libq_core.so
-- The incfile contains
-- 1) all typedef statements
-- 2) all function prototypes
-- The incfile is created by concatenating all the .h files for Q
-- with the condition that the typedef struct statements should precede
-- their usage
-- The sofile is the .so file created by aggregating the .o files 
-- which are in turn created by compiling all the .c files for Q
--
-- Dynamic versus static compilation
-- In the case of dynamic compilation, the incfile and sofile referenced 
-- above will be quite small and will contain the bare essentials
-- In the case of static compilation, they are likely to be quite large
--
-- Regardless, they need to exist before we can continue

assertx(cutils.isfile(incfile), "File not found ", incfile)
local str = assert(cutils.read(incfile))
assert(#str > 0)
ffi.cdef(str)

assertx(cutils.isfile(sofile), "File not found ", sofile)
local q_static = ffi.load(sofile) -- statically compiled library
-- had we done no dynamic compilation, we would have
-- returned q_static and we would be done
--=========================================================

local known_functions = {}  -- this is to make sure that we do not dynamically compile the same function twice 
local qc              = {}  -- what we will return
local libs            = {}  -- Subtle but important reason why we have this here. Explained further down.


local function get_val_in_q_static(val)
  return q_static[val]
end

-- Important: Note that there are 2 places where load_liob is called from
-- 1) add_lib -> this is done whenever Q restarts
-- 2) q_add   -> this is dynamic compilation
local function load_lib(
  hfile
  )
  -- If hfile is "/foo/bar/x.h", then file is "x.h"
  local file = hfile:match('[^/]*$')
  assert(#file >= 3, "At least one character other than .h ")

  -- If file = "x.h", func_name = "x" and num_subs == 1 
  local func_name, num_subs = file:gsub("%.h$", "")
  assert(#func_name > 0)
  assert(num_subs == 1, "Should have a .h extension")

  func_name, num_subs = string.gsub(func_name,"^_", "")
  assert(num_subs == 1, "Should start with  underscore")

  -- verify that func_name is not in q_static
  local status, _ = pcall(get_val_in_q_static, func_name)
  assert( not status)

  -- verify that function name not seen before
  assertx(not known_functions[func_name],
    "Function already declared: ", func_name)

  local so_name = "lib" .. func_name 
  assert(so_name ~= "libq_core", 
    "Specical case. Qcore should not be loaded with load_lib()")

  -- Important to pcall and then assert status so that
  -- you can identify the culprit hfile
  local full_hfile = inc_dir .. "_" .. func_name .. ".h"
  local status, err_msg = pcall(ffi.cdef, cutils.read(full_hfile))
  assert(status, " Unable to cdef the .h file " .. full_hfile)
  -- check that .so file exists
  local so_file = lib_dir .. so_name .. ".so"
  assertx(cutils.isfile(so_file), "File not found " .. so_file)
  local L = ffi.load(so_name)
  -- Now that cdef and load have worked, keep track of it
  -- if you don't store L outside the scope of this function, 
  -- then it gets garbage collected 
  -- and when you try and invoke qc.foo, the program crashes
  print("Added previous dynamic ", func_name)
  libs[func_name] = L
  known_functions[func_name] = libs[func_name][func_name]
  qc[func_name] = libs[func_name][func_name]
  return true
end

-- Pseudo code:
-- 1: list all the .h files in the inc_dir (excluding q_core.h)
-- 2: For each such file foo, call load_lib(foo)
-- 3: Confirm that you did see a file called q_core.h
local function add_libs()
  -- After a make clean and a fresh build of Q, the only .h file in
  -- inc_dir will be q_core.h. If dynamic compilation is on and new 
  -- symbols are compiled, then a .h file will exist for each new 
  -- symbol in inc_dir. Do NOT corrupt this directory with any other
  -- .h files!!!
  local hfiles = cutils.getfiles(inc_dir, ".*.h$", "only_files")
  local found_qcore = false
  for _, hfile in pairs(hfiles) do 
    if not hfile:find("q_core.h") then 
      assert(load_lib(hfile))
    else
      found_qcore = true
    end
  end
  assert(found_qcore, "q_core.h must exist in the search path")
end

-- q_add is used by Q opertors to dynamically add a symbol that is missing
-- Differs from all other symbols in q_static/qt in this important regard.
local function q_add(
  subs 
  )
  -- the fact that we come here => q_static does not have this symbol
  -- we neeed to do the following

  local tmpl, doth, dotc
  -- EITHER provide a tmpl OR the doth and dotc 
  assert(type(subs) == "table")
  if ( subs.tmpl ) then 
    assert(not subs.doth) assert(not subs.dotc)
    tmpl = subs.tmpl
    assert( (type(tmpl) == "string") and  ( #tmpl > 0 ) )
  else
    doth = subs.doth
    assert( (type(doth) == "string") and  ( #doth > 0 ) )
    dotc = subs.dotc
    assert( (type(dotc) == "string") and  ( #dotc > 0 ) )
  end
  local function_name = assert(subs.fn)
  assert( (type(function_name) == "string") and  ( #function_name > 0 ) )

  assert(not known_functions[function_name], "Function already registered")
  assert(not qc[function_name], "Function already registered")
  --==================================
  local type_doth_dotc
  if tmpl then 
    type_doth_dotc = "strings"
    assert(type(tmpl) == "string")
    doth = gen_code.doth(subs, "") -- this is string containing .h file
    dotc = gen_code.dotc(subs, "") -- this is string containing .c file
  else
    type_doth_dotc = "files"
    assert(type(dotc) == "string")
    assert(type(doth) == "string")
    assert(cutils.isfile(dotc))
    assert(cutils.isfile(doth))
  end
  --==================================
  -- Note the underscore which is convention for generated files
  local hfile  = inc_dir           .. "_" .. function_name .. ".h"
  local sofile = lib_dir .. "/lib" .. function_name .. ".so"
  
  assert(not cutils.isfile(hfile),  ".h  file should not pre-exist")
  assert(not cutils.isfile(sofile), ".so file should not pre-exist")
  --==================================

  compile(doth, dotc, type_doth_dotc, function_name, hfile, sofile)
  load_lib(hfile)
end

local qc_mt = {
  __newindex = function(self, key, value)
    -- Write more details on why you might want to redfine a function
    -- Might want to protect this with a qconsts.debug e.g.
    -- assert(qconsts.debug)
    rawset(self, key, value)
    -- If you genuinely believe that you do not want to give the developer
    -- this ability, then
    -- error("you cannot redfine a function")
  end,
  __index = function(self, key)
    -- the very fact that you came here means that this "key" was 
    -- not a dynamically generated function
    -- for a statically generated function, you come here only once
    if key == "q_add" then return q_add end
    -- get it from q_static (all statically compiled stuff)
    -- print("getting from q_static ", key)
    local status, func = pcall(get_val_in_q_static, key)
    if status == true then
      qc[key] = func 
      return func
    else
      -- Returning nil is our way of telling the caller that the symbol
      -- does not exist and they had better invoke dynamic compilation
      return nil
    end
  end
}
setmetatable(qc, qc_mt)
add_libs() 
print("Initial qc completed")
return qc
--[[ Some explanation of index method on metatables
If we did qcjfoo, then 
  if qcjfoo ~= nil then 
    return it
  else
    the __index function would be invoked
    What does our __index function do?
    It checks to see if this is available in qc using get_val_in_q_static()
    But we protect this with a pcall so that we don't bomb out
    If status from pcall is true then
       It means that the "func" you get back is what qc had
       Do qcjkey] = func to prevent __index from being called again
       Return "func"
    else
    end
  end
end
2 cases 
-- (1) qcjfoo refers to some known C function and we return it
-- (2) 
--]]
