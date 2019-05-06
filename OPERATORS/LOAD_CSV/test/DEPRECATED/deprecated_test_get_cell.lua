-- TODO IMPORTANT. export LD_LIBRARY_PATH=$PWD
local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path .. ";" .. rootdir .. "/UTILS/lua/?.lua"
local plpath  = require 'pl.path'
local log = require 'log'
require 'utils'
local compile_so = require 'compile_so'
require 'extract_fn_proto'
local ffi = require 'ffi'
local cfile = "../src/get_cell.c"
local get_cell_h = assert(extract_fn_proto("../src/get_cell.c"))
local mmap_h = extract_fn_proto(rootdir .. "/UTILS/src/f_mmap.c")
local mmap_types_h = load_file_as_string(rootdir .. "/UTILS/inc/mmap_types.h")
mmap_types_h = string.gsub(mmap_types_h, "#.-\n", "")
--============================
local nargs = assert(#arg == 3, "Arguments are <nrows> <ncols> <infile>")
local nrows = assert(tonumber(arg[1]))
local ncols = assert(tonumber(arg[2]))
local infile = arg[3]
assert(plpath.isfile(infile), "File not found")
local instr = load_file_as_string(infile)
local nX = string.len(instr)
local xidx = 0
local rowidx = 0
local colidx = 0
local bufsz = 32
ffi.cdef( [[
void *malloc(size_t size);
void free(void *ptr);
]]
)
ffi.cdef(get_cell_h)
ffi.cdef(mmap_types_h)
ffi.cdef(mmap_h)
local buf = ffi.gc(ffi.C.malloc(bufsz), ffi.C.free) 
is_last_col = false
-- Create libget_cell.so
incs = { "../../../UTILS/inc/", "../../../UTILS/gen_inc/", "../gen_inc/"}
srcs = { "../src/get_cell.c", "../../../UTILS/src/f_mmap.c" }
tgt = "libget_cell.so"
local status = assert(compile_so(incs, srcs, tgt), "compile of .so failed")
local get_cell = assert(ffi.load("get_cell.so").get_cell)
local f_mmap   = assert(ffi.load("get_cell.so").f_mmap)
local M = assert(f_mmap(infile, 0))
X = M.ptr_mmapped_file
nX = tonumber(M.file_size)

-- dbg()
local xidx = 0
for rowidx = 1, nrows, 1 do 
  for colidx = 1, ncols, 1 do 
    if ( colidx == ncols ) then
      is_last_col = true
    else
      is_last_col = false
    end
    xidx = tonumber(get_cell(X, nX, xidx, is_last_col, buf, bufsz))
    assert(xidx > 0, "rowidx/colidx = " .. rowidx .. "/" .. colidx)
  end
end
assert(tonumber(xidx))
assert(tonumber(nX))
assert(tonumber(xidx) == tonumber(nX), "xidx != nX")
log.info("All is well")

