local assertx  = require 'Q/UTILS/lua/assertx'
local compile  = require 'Q/UTILS/lua/compile'
local ffi      = require 'ffi'
local gen_code = require 'Q/UTILS/lua/gen_code'
local for_cdef = require 'Q/UTILS/build/for_cdef'
local qconsts  = require 'Q/UTILS/lua/q_consts'

--=== From runtime
local cutils  = require 'libcutils'
local cmem    = require 'libcmem'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
--==================
local Q_SRC_ROOT   = qconsts.Q_SRC_ROOT .. "/"
local Q_ROOT       = qconsts.Q_ROOT .. "/"
local lib_dir = Q_ROOT .. "/lib/"
assert(cutils.isdir(Q_SRC_ROOT))
assert(cutils.isdir(Q_ROOT))
assert(cutils.isdir(lib_dir))

-- to make sure we do not dynamically compile the same function twice 
local known_functions = {}  
-- what we will return
local qc              = {}  
-- Subtle but important reason why we have this here. Explained later
local libs            = {}  

-- TODO P1: Can we get rid of below?
local function get_val_in_q_static(val)
  return q_static[val]
end

local function load_lib(
  fn,
  hfile,
  incs,
  structs,
  sofile
  )
  -- cdef the .h file with the function declaration
  local y = for_cdef(hfile, incs)
  status, msg = pcall(ffi.cdef, y)
  assert(status, "Unable to cdef the file " .. hfile)
  --=== cdef the struct files, if any
  if ( structs ) then
    for _, v in pairs(structs) do 
      local y = for_cdef(v, incs)
      status, msg = pcall(ffi.cdef, y)
    end
  end
  --[[ TODO P1 
  local status, _ = pcall(get_val_in_q_static, fn)
  assert( not status)
  --]]

  -- verify that function name not seen before
  assertx(not known_functions[fn],
    "Function already declared: ", fn)

  local L = ffi.load(sofile)
  -- Now that cdef and load have worked, keep track of it
  -- if you don't store L outside the scope of this function, 
  -- then it gets garbage collected 
  -- and when you try and invoke qc.foo, the program crashes
  print("Added function to qc ", fn)
  libs[fn] = L
  known_functions[fn] = libs[fn][fn]
  qc[fn] = libs[fn][fn]
  return true
end

-- q_add is used by Q opertors to dynamically add a symbol that is missing
local function q_add(
  subs 
  )
  local tmpl, doth, dotc
  -- EITHER provide a tmpl OR the doth and dotc 
  assert(type(subs) == "table")
  if ( subs.tmpl ) then 
    assert(not subs.doth) assert(not subs.dotc)
    tmpl = subs.tmpl
    assert( (type(tmpl) == "string") and  ( #tmpl > 0 ) )
    doth = gen_code.doth(subs, subs.incdir) -- this creates a .h file
    dotc = gen_code.dotc(subs, subs.srcdir) -- this created a .c file
  else
    doth = subs.doth
    assert( (type(doth) == "string") and  ( #doth > 0 ) )
    dotc = subs.dotc
    assert( (type(dotc) == "string") and  ( #dotc > 0 ) )
    doth = Q_SRC_ROOT .. doth
    dotc = Q_SRC_ROOT .. dotc
  end
  assert(cutils.isfile(dotc))
  assert(cutils.isfile(doth))
  local fn = assert(subs.fn)
  assert( (type(fn) == "string") and  ( #fn > 0 ) )

  assert(not known_functions[fn], "Function already registered")
  assert(not              qc[fn], "Function already registered")
  --==================================
  local sofile = assert(compile(dotc, subs.srcs, subs.incs, subs.libs, fn))
  load_lib(fn, doth, subs.incs, subs.structs, sofile)
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
--
--[[ TODO P3 Delete this later I don't think we need i any more
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
--]]
