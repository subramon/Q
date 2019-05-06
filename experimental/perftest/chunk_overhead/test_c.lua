local qc = require 'Q/UTILS/lua/q_core'
local ffi = require 'Q/UTILS/lua/q_ffi'
local Q = require 'Q'
-- local dbg = require 'Q/UTILS/lua/debugger'
local qc      = require 'Q/UTILS/lua/q_core'
local filenm = arg[1]
local Column = require 'Q/RUNTIME/COLUMN/code/lua/Column'
local col = Column{field_type='I4', filename=filenm,}
local dest_file = os.getenv("Q_DATA_DIR") .. "/cout.bin"
os.remove(dest_file)
local function add_test(ptr1,size1, ptr2, size2)
   assert(size1 == size2 , "Chunks must be of same length")
   local res_chunk = ffi.cast("int*", ffi.malloc(size1 * ffi.sizeof("int")))
   qc["vvadd_I4_I4_I4"](ptr1, ptr2, size1, res_chunk)
   fd = ffi.C.fopen(dest_file, "wb+")
   ffi.C.fwrite(res_chunk, ffi.sizeof("int"), col:length(), fd)
   ffi.C.fclose(fd)
   return 
end


-- local z = Q.vvadd(col,col, {junk = "junk"})
local size1, chunk1 = col:chunk(-1)
local size2, chunk2 = col:chunk(-1)

local start_time = qc.RDTSC()
add_test(chunk1, size1, chunk2, size2))
local stop_time = qc.RDTSC()
print("time taken", stop_time-start_time)
