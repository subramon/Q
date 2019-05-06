local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local cmem    = require 'libcmem'
local lVector = require 'Q/RUNTIME/lua/lVector'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local function expander_gen3(f1, f2)
  -- start: hard coding for this test case
  local counter = 1
  local chunk_size = qconsts.chunk_size
  local qtype = "I4"
  -- stop : hard coding for this test case
  local field_size = qconsts.qtypes[qtype].width
  local base_data = cmem.new(chunk_size * field_size)
  local out_ptr = get_ptr(base_data, qtype)
   -- currently exapnds f1 with the number of times given in f2
   local state = {}
   local function gen3(chunk_idx, col)
      local start_f1, f1_len, f1_chunk, f1_chunk_num
      local start_f2, f2_len, f2_chunk, f2_chunk_num
      local count, init_count
      if state.prev == nil then
        f1_chunk_num = chunk_idx
        f2_chunk_num = chunk_idx
        start_f1 = 1
        start_f2 = 1
        init_count = 0 
      else
        f1_chunk_num = state.prev.f1_chunk_num
        f2_chunk_num = state.prev.f2_chunk_num
        start_f1 = state.prev.start_f1
        start_f2 = state.prev.start_f2
        init_count = state.prev.count
      end
      local data_size = 0 -- signifying that the chunk is empty
      repeat
        print("f1_chunk_num = ", f1_chunk_num)
         f1_len, f1_chunk = f1:chunk(f1_chunk_num)
         f2_len, f2_chunk = f2:chunk(f2_chunk_num)
	 if ( (f1_len == 0) or (f2_len == 0) or 
              (f1_len == nil) or (f2_len == nil) ) then
	    return data_size, base_data, nil
         end
	 f2_chunk = ffi.cast("int*", f1_chunk)
	 f1_chunk = ffi.cast("int*", f1_chunk)
         for f1_index=start_f1, f1_len do
	    local f1_val = f1_chunk[f1_index - 1]
            for f2_index = start_f2, f2_len do
               local f2_val = f2_chunk[f2_index - 1]
               for iter=init_count, f2_val do
		  out_ptr[data_size] = f1_val
                  -- check if full
                  if data_size + 1 == chunk_size then
		     local prev = {}
                     prev.start_f1 = f1_index
                     prev.start_f2 = f2_index
                     -- TODO fix so that previous chunk is not asked for aka
                     -- boundary condition
                     prev.count = iter + 1
                     prev.curr_chunk = chunk_idx
                     state.prev = prev
                     return chunk_size, base_data, nil
                   else
                     data_size = data_size + 1
		   end
               end
            end
         end
         f1_chunk_num  = f1_chunk_num + 1
         f2_chunk_num = f2_chunk_num + 1
      until false
      return data_size, base_data, nil
   end
   return gen3
end
return expander_gen3
