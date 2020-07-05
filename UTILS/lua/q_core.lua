local assertx  = require 'Q/UTILS/lua/assertx'
local compile  = require 'Q/UTILS/lua/compile'
local ffi      = require 'ffi'
local gen_code = require 'Q/UTILS/lua/gen_code'
local for_cdef = require 'Q/UTILS/lua/for_cdef'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local cutils  = require 'libcutils'
local Q_SRC_ROOT   = qconsts.Q_SRC_ROOT .. "/"
assert(cutils.isdir(Q_SRC_ROOT))
--==================

-- to make sure we do not dynamically compile the same function twice
local known_functions = {}
-- what we will return
local qc              = {}
-- Subtle but important reason why we have this here. Explained later
local libs            = {}
-- Keeps track of struct files that have been cdef'd
local cdefd = {}

local function q_cdef( infile, incs)
  if ( cdefd[infile] ) then
    -- print("struct file: Skipping cdef of " .. infile)
  else
    -- print("cdef'ing " .. infile)
    local y = for_cdef(infile, incs)
    ffi.cdef(y)
    cdefd[infile] = true
   end
end

local function load_lib(
  fn,
  doth,
  incs,
  structs,
  sofile
  )
  local cdefs = {}
  --=== cdef the struct files, if any
  if ( structs ) then
    for _, v in pairs(structs) do
      if ( cdefd[v] ) then
        -- print("struct file: Skipping cdef of " .. v)
      else
        -- print("cdef'ing " .. v)
        local y = for_cdef(v, incs)
        ffi.cdef(y)
        cdefs[v] = y
        cdefd[v] = true
      end
    end
  end
  -- This needs to be done AFTER the structs have been cdef'd
  -- cdef the .h file with the function declaration
  if ( cdefd[doth] ) then
    -- print("doth: Skipping cdef of " .. doth)
  else
    local y = for_cdef(doth, incs)
    ffi.cdef(y)
    cdefd[doth] = true
    cdefs[doth] = y
  end
  -- verify that function name not seen before
  assertx(not known_functions[fn], "Function already declared: ", fn)

  local L = assert(ffi.load(sofile))
  assert(L[fn])
  -- Now that cdef and load have worked, keep track of it
  -- if you don't store L outside the scope of this function,
  -- then it gets garbage collected
  -- and when you try and invoke qc.foo, the program crashes
  -- print("Added function to qc ", fn)
  libs[fn] = L
  known_functions[fn] = libs[fn][fn]
  qc[fn] = libs[fn][fn]
  return cdefs
end

-- q_add is used by Q opertors to dynamically add a symbol that is missing
local function q_add(
  subs
  )
  local tmpl, doth, dotc
  local fn = assert(subs.fn)
  if ( known_functions[fn] ) then
    -- print("Nothing to do: Known function " .. fn) return true
  end

  -- EITHER provide a tmpl OR the doth and dotc, not both
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
  end
  assert( (type(fn) == "string") and  ( #fn > 0 ) )

  assert(not known_functions[fn], "Function already registered")
  assert(not              qc[fn], "Function already registered")
  --==================================
  local sofile = assert(compile(dotc, subs.srcs, subs.incs, subs.libs, fn))
  local cdefs = load_lib(fn, doth, subs.incs, subs.structs, sofile)
  assert(type(cdefs) == "table")
  return true
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
  -- TODO P2: luacheck says     q_core.lua:125:22: unused argument self
  __index = function(self, key)
    if key == "q_add" then return q_add end
    if key == "q_cdef" then return q_cdef end
  end
}
setmetatable(qc, qc_mt)
return qc
