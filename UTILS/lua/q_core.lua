-- local dbg = require 'Q/UTILS/lua/debugger'
local qconsts = require 'Q/UTILS/lua/q_consts'

local Q_ROOT      = qconsts.Q_ROOT 

local assertx  = require 'Q/UTILS/lua/assertx'
local compile  = require 'Q/UTILS/lua/compile'
local ffi      = require 'ffi'
local gen_code = require 'Q/UTILS/lua/gen_code'
local fileops  = require 'Q/UTILS/lua/fileops'
local qconsts  = require 'Q/UTILS/lua/q_consts'

local sofile   = Q_ROOT .. "/lib/libq_core.so"
local incfile  = Q_ROOT .. "/include/q_core.h"
local inc_dir  = Q_ROOT .. "/include/"
local lib_dir  = Q_ROOT .. "/lib/"

-- START: Put in a bunch of cdefs that we will need later
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
typedef struct tm
{
  int tm_sec;			/* Seconds.	[0-60] (1 leap second) */
  int tm_min;			/* Minutes.	[0-59] */
  int tm_hour;			/* Hours.	[0-23] */
  int tm_mday;			/* Day.		[1-31] */
  int tm_mon;			/* Month.	[0-11] */
  int tm_year;			/* Year	- 1900.  */
  int tm_wday;			/* Day of week.	[0-6] */
  int tm_yday;			/* Days in year.[0-365]	*/
  int tm_isdst;			/* DST.		[-1/0/1]*/

  long int __tm_gmtoff;		/* Seconds east of UTC.  */
  const char *__tm_zone;	/* Timezone abbreviation.  */
} TM ; 
   ]])
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
-- TODO P2: Need to be more disciplined about what is available in the
-- minimal case
--
-- Regardless, they need to exist before we can continue

assertx(fileops.isfile(incfile), "File not found ", incfile)
ffi.cdef(fileops.read(incfile))

assertx(fileops.isfile(sofile), "File not found ", sofile)
local qc = ffi.load(sofile) -- statically compiled library
--=========================================================

local function_lookup = {}
local qt              = {}  -- for all dynamically compiled stuff
local libs            = {}

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

  -- verify that func_name is not in qc
  print("XX", func_name)
  assert( not qc[func_name])


  -- verify that function name not seen before
  assertx(function_lookup[func_name] == nil,
    "Library name is already declared: ", func_name)

  local so_name = "lib" .. func_name .. ".so"
  assert(so_name ~= "libq_core.so", 
    "Specical case. Qcore should not be loaded with load_lib()")

  -- INDRA: Why do we pcall? Why not fail?
  local status, err_msg = pcall(ffi.cdef, fileops.read(hfile))
  assert(status, err_msg .. " Unable to cdef the .h file " .. hfile)
  local status, L = pcall(ffi.load, so_name)
  assert(status, " Unable to load .so file " .. so_name)
  -- Now that cdef and load have worked, keep track of it
  libs[func_name] = L
  function_lookup[func_name] = libs[func_name][func_name]
  qt[func_name] = libs[func_name][func_name]
end

-- Pseudo code:
-- 1: list all the .h files in the inc_dir (excluding q_core.h)
-- 2: For each such file foo, call load_lib(foo)
-- 3: Confirm that you did see a file called q_core.h
local function add_libs()
  local hfiles = fileops.list_files_in_dir(inc_dir, "*.h")
  local found_qcore = false
  for _, hfile in pairs(hfiles) do 
    if not hfile:find("q_core.h") then 
      load_lib(hfile)
    else
      found_qcore = true
    end
  end
  assert(found_qcore, "q_core.h must exist in the search path")
end

local function get_qc_val(val)
  return qc[val]
end

-- q_add is used by Q opertors to dynamically add a symbol that is missing
-- Differs from all other symbols in qc/qt in this important regard.
local function q_add(
  doth, -- full path of .h file OR a table of substitutions
  dotc, -- full path of .c file OR a template file 
  function_name -- name of symbol to be added
  )
  -- the fact that we come here means that qc does not have this symbol
  -- we neeed to do the following
  -- 1) If the dotc/doth files are not provided, generate them
  -- INDRA:  Why look in 2 places below?
  assert(doth)
  assert(dotc)
  assert( (type(function_name) == "string") and  ( #function_name > 0 ) )

  assert(not function_lookup[function_name], "Function already registered")
  assert(not qt[function_name], "Function already registered")
  --==================================
  if type(doth) == "table" then -- means this is subs and tmpl
    local subs, tmpl = doth, dotc
    assert(type(tmpl) == "string")
    doth = gen_code.doth(subs, tmpl) -- this is string containing .h file
    dotc = gen_code.dotc(subs, tmpl) -- this is string containing .c file
  end
  assert(type(dotc) == "string")
  assert(type(doth) == "string")
  --==================================
  local hfile  = inc_dir           .. function_name .. ".h"
  local sofile = lib_dir .. "/lib" .. function_name .. ".so"
  
  assert(not fileops.isfile(hfile),  ".h  file should not pre-exist")
  assert(not fileops.isfile(sofile), ".so file should not pre-exist")
  --==================================

  compile(doth, dotc, hfile, sofile, function_name)
  load_lib(hfile)
end

local qc_mt = {
  __newindex = function(self, key, value)
    -- INDRA DISCUSS 
    rawset(self, key, value)
    -- assert(nil) --- You cannot define a function this way. Use q_add()
  end,
  __index = function(self, key)
    -- the very fact that you came here means that this "key" was 
    -- not a dynamically generated function
    -- for a statically generated function, you come here only once
    if key == "q_add" then return q_add end
    -- get it from qc (all statically compiled stuff)
    -- INDRA: Why pcall? Why not die?
    local status, func = pcall(get_qc_val, key)
    if status == true then
      qt[key] = func 
      return func
    else
      return nil
    end
  end
}
setmetatable(qt, qc_mt)
add_libs() 
return qt
