local ffi = require "ffi"
local qconsts = require "Q/UTILS/lua/q_consts"

ffi.cdef([[
void *memset(void *s, int c, size_t n);
void *memcpy(void *dest, const void *src, size_t n);
void * malloc(size_t size);
void free(void *ptr);
int
load_csv_fast(
    const char * const q_data_dir,
    const char * const infile,
    uint32_t nC,
    uint64_t *ptr_nR,
    const char ** fldtypes, /* [nC] */
    bool is_hdr, /* [nC] */
    bool * is_load, /* [nC] */
    bool * has_nulls, /* [nC] */
    uint64_t * num_nulls, /* [nC] */
    char ***ptr_out_files,
    char ***ptr_nil_files,
    /* Note we set nil_files and out_files only if below == NULL */
    char *str_for_lua,
    size_t sz_str_for_lua,
    int *ptr_n_str_for_lua 
    );
]])

-- TODO: Put this back later ffi.new = nil 


local function load_csv_fast_C(i)

  x = ffi.load("./load_csv_fast.so")
  local nR = ffi.cast("uint64_t *", 
             ffi.gc(
                ffi.C.malloc(ffi.sizeof("uint64_t")), ffi.C.free))
  nR[0] = 0
  nC = 5
  local fldtypes = ffi.gc(ffi.C.malloc(nC * ffi.sizeof("char *")), ffi.C.free)
  fldtypes = ffi.cast("const char **", fldtypes)
  
  local is_load = ffi.gc(ffi.C.malloc(nC * ffi.sizeof("bool")), ffi.C.free)
  is_load = ffi.cast("bool *", is_load)

  local has_nulls = ffi.gc(ffi.C.malloc(nC * ffi.sizeof("bool")), ffi.C.free)
  has_nulls = ffi.cast("bool *", has_nulls)  
  
  local num_nulls = ffi.gc(ffi.C.malloc(nC * ffi.sizeof("uint64_t")), ffi.C.free)
  num_nulls = ffi.cast("uint64_t *", num_nulls)

  local fld_name_width = 4 -- TODO Undo this hard coiding
  for i = 1, nC do
    fldtypes[i-1] = ffi.gc(ffi.C.malloc(fld_name_width * ffi.sizeof("char")), ffi.C.free)
    fldtypes[i-1] = ffi.cast("const char *", fldtypes[i-1])
    num_nulls[i-1] = 0
  end
  fldtypes[0] = "I8"
  fldtypes[1] = "SC"
  fldtypes[2] = "I4"
  fldtypes[3] = "SC"
  fldtypes[4] = "F8"

  is_load[0] = true
  is_load[1] = false
  is_load[2] = true
  is_load[3] = false
  is_load[4] = true

  has_nulls[0] = false
  has_nulls[1] = false
  has_nulls[2] = false
  has_nulls[3] = false
  has_nulls[4] = false

  local out_files = nil
  local nil_files = nil 

  local sz_str_for_lua = qconsts.sz_str_for_lua

  local str_for_lua = ffi.gc(ffi.C.malloc(sz_str_for_lua), ffi.C.free)
  str_for_lua = ffi.cast("char *", str_for_lua)
  ffi.copy(str_for_lua, "01234567890123456789012345678901234567890123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ");

  local n_str_for_lua = ffi.gc(ffi.C.malloc(ffi.sizeof("int")), ffi.C.free)
  n_str_for_lua = ffi.cast("int *", n_str_for_lua)
  n_str_for_lua[0] = 0

  data_dir = "/home/subramon/local/Q/data/"
  infile = "/home/subramon/WORK/Q/TESTS/AB1/data/eee_1.csv"

  local is_hdr = true

  local status = x.load_csv_fast(data_dir, infile, nC, nR, fldtypes,
  is_hdr, is_load, has_nulls, num_nulls, out_files, nil_files,
  str_for_lua, sz_str_for_lua, n_str_for_lua);

  --[[
  if ( ( i % 1000 ) == 1 ) then
    print(ffi.string(str_for_lua))
  end
  --]]
end

niter = 1000000
datadir = "/home/subramon/local/Q/data/"  -- FIX TODO 
command = "rm -f " .. datadir .. "/_*"
os.execute(command)
for i = 1, niter do
  load_csv_fast_C(i)
  if ( ( i % 1000 ) == 0 ) then
    print("iter = ", i)
    os.execute(command)
    collectgarbage()
  end
end
os.execute(command)
print("ALL DONE")
