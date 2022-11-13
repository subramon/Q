local assertx  = require 'Q/UTILS/lua/assertx'
local compile  = require 'Q/UTILS/lua/compile'
local link     = require 'Q/UTILS/lua/link'
local compile_and_link  = require 'Q/UTILS/lua/compile_and_link'
local is_so_file  = require 'Q/UTILS/lua/is_so_file'
local ffi      = require 'ffi'
local gen_code = require 'Q/UTILS/lua/gen_code'
local for_cdef = require 'Q/UTILS/lua/for_cdef'
local qcfg     = require 'Q/UTILS/lua/qcfg'
local cutils   = require 'libcutils'
--==================

-- IMPORTANT: Place things here that you are likely to need via ffi
-- e.g., ffi.C.malloc, etc 
ffi.cdef([[
       void *memcpy(void *dest, const void *src, size_t n);
       void *malloc(size_t size);
       void free(void *ptr);
       ]]);

-- to make sure we do not dynamically compile the same function twice
local known_functions = {}
-- what we will return
local qc              = {}
-- Subtle but important reason why we have this here. Explained later
local libs            = {}
-- Keeps track of struct files that have been cdef'd
local cdefd = {}

-- IMPORTANT: Document the assumption that no two files that can
-- be sent to cdef can have the same struct in them
-- we need q_cdef instead of just cdef because we do not want
-- to error out by repeating a cdef that was done earlier
local function q_cdef( infile, incs)
  if ( cdefd[infile] ) then
    -- print("Skipping cdef of " .. infile)
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
  sofile,
  subs
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
    -- print("doth: cdef'ing " .. doth)
    local y = for_cdef(doth, incs, subs)
    -- print("cdefing ", y)
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
  known_functions[fn] = true
  qc[fn] = libs[fn][fn]
  return cdefs
end

-- q_add is used by Q opertors to dynamically add a symbol that is missing
local function q_add(
  subs
  )
  local tmpl, doth, dotc, ispc
  local fn = assert(subs.fn)
  if ( known_functions[fn] ) then assert(qc[fn]) end
  if ( not known_functions[fn] ) then assert(not qc[fn]) end
  if ( known_functions[fn] ) then
    -- print("Nothing to do: Known function " .. fn)
    return true
  end

  -- EITHER provide a tmpl OR the doth and dotc, not both
  assert(type(subs) == "table")
  assert( (type(fn) == "string") and  ( #fn > 0 ) )
  --=================================================
  if ( subs.tmpl ) then
    assert(not subs.doth) assert(not subs.dotc)
    tmpl = subs.tmpl
    assert( (type(tmpl) == "string") and  ( #tmpl > 0 ) )
    doth = gen_code.doth(subs, subs.incdir) -- creates a .h file
    dotc = gen_code.dotc(subs, subs.srcdir) -- creates a .c file
  else
    doth = subs.doth
    assert( (type(doth) == "string") and  ( #doth > 0 ) )
    dotc = subs.dotc
    assert( (type(dotc) == "string") and  ( #dotc > 0 ) )
  end
  --============================================
  if ( subs.tmpl_ispc ) then
    assert(not subs.isph) assert(not subs.ispc)
    -- creates a .ispc file and corresponding .h file
    ispc = gen_code.ispc(subs, subs.srcdir, subs.incdir)
  else
    ispc = subs.ispc -- Optional, hence no assert on it
  end
  --==================================
  -- PROCESS ISPC after this
  local is_so, sofile = is_so_file(subs.fn)
  if ( not is_so ) then
    if ( not ispc ) then
      assert(compile_and_link( dotc, subs.srcs, subs.incs, subs.libs, fn))
    else
      local dotos      = assert(
        compile("C", dotc, subs.srcs, subs.incs))
      dotos = assert(
        compile("ISPC", ispc, subs.srcs_ispc, subs.incs_ispc, dotos))
      assert(link(dotos, subs.libs, subs.libs_ispc, sofile))
    end
  end

  local cdefs = load_lib(fn, doth, subs.incs, subs.structs, sofile, subs)
  assert(type(cdefs) == "table")

  return true
end

qc.q_add  = q_add
qc.q_cdef = q_cdef
return qc
