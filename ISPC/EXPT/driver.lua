local ffi = require 'ffi'
ffi.cdef("void *malloc(size_t size);")
ffi.cdef([[
uint32_t fasthash32(const void *buf, size_t len, uint32_t seed);
uint64_t fasthash64(const void *buf, size_t len, uint64_t seed);
]])
local hash = ffi.load("libfasthash.so")
local gen_code = require 'gen_code'
--==================
local plpath = require 'pl.path'
local plfile = require 'pl.file'
assert(type(arg) == "table")
local infile = assert(arg[1], "provide input file")
assert(plpath.isfile(infile), "input file missing")
local T = dofile(infile)

local test_str = arg[2] 
--==================
ffi.cdef([[
typedef struct _strcmp_ht_t { 
  uint64_t *vals;
  int nvals;
  int mvals;
  uint64_t seed;
} strcmp_ht_t;
]])
local sz = ffi.sizeof("strcmp_ht_t");
local X = ffi.C.malloc(sz)
ffi.fill(X, sz)
X = ffi.cast("strcmp_ht_t *", X)
X[0].seed = os.clock()
--==================
assert(gen_code(X, T, hash))
assert(X[0].vals)
assert(type(X[0].nvals) == "number")
assert(X[0].nvals > 0)
assert(type(X[0].mvals) == "number")
assert(X[0].mvals >= X[0].nvals)
print("Created struct ")
--==================
-- Create a custom .so file for lookups
local x = "#define N " .. tostring(X[0].mvals)
local y = plfile.read("str_in_set.ispc")
local z = string.gsub(y, "#define N 1", x)
local tmpc = "/tmp/_foo.ispc"
local tmpo = string.gsub(tmpc, ".ispc",".o")
local sofile = "libstr_in_set.so"
plfile.write(tmpc, z)
local cmd = {}
cmd[#cmd+1] = "ispc --pic -O3 " .. tmpc ..  " -o " .. tmpo
cmd[#cmd+1] = "gcc -fPIC -O4 -c str_in_set.c -o /tmp/str_in_set.o"
cmd[#cmd+1] = "gcc -fPIC -O4 -c fasthash.c -o /tmp/fasthash.o" 
cmd[#cmd+1] = "gcc /tmp/fasthash.o /tmp/str_in_set.o " .. tmpo .. 
  " -shared -o " .. sofile 
cmd = table.concat(cmd, "\n")
local status = os.execute(cmd)
assert(status == 0)
plpath.isfile(sofile)
print("Created sofile ")
--==================
if ( test_str ) then 
  local h = hash["fasthash64"](test_str, #test_str, X[0].seed)
  -- first look the slow way 
  local found = false
  for i = 1, X[0].mvals do 
    if ( X.vals[i-1] == h ) then
      found = true
    end
  end
  if ( found ) then print("Found") else print("Missing") end 
  -- now look the fast way 
  ffi.cdef([[ 
extern bool 
str_in_set(
    const char * const str,
    const strcmp_ht_t *const X
    );
    ]])
  local str_in_set = ffi.load("libstr_in_set.so")
  local found = str_in_set.str_in_set(test_str, X);
  if ( found ) then print("Found") else print("Missing") end 
end
