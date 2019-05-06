local ffi	= require 'Q/UTILS/lua/q_ffi'
local cmem	= require 'libcmem'
local qc	= require 'Q/UTILS/lua/q_core'


local function mem_initialize(subs)
  local args_ctype = "SPOOKY_STATE"
  local cst_args_as = args_ctype .. " *"
  local sz_args = ffi.sizeof(args_ctype)
  local args = assert(cmem.new(sz_args), "malloc failed")
  local args_ptr = ffi.cast(cst_args_as, args)
  args:zero()
  -- Following normally done by spooky_hash_init()
  args_ptr[0].m_length   = 0;
  args_ptr[0].m_remainder  = 0;
  args_ptr[0].m_state[0] = subs.seed1
  args_ptr[0].m_state[1] = subs.seed2
  -- needed by Q
  args_ptr[0].q_seed     = subs.seed
  args_ptr[0].q_stride   = subs.stride
  return args_ptr
end

return mem_initialize
