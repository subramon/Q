local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

return function (col, rowidx)
  --TODO: Handle B1 case
  --TODO: Check for caching of chunk
  local val = nil
  local nn_val = nil
  local chunk_num = math.floor((rowidx-1)/qconsts.chunk_size)
  local chunk_idx = (rowidx-1) % qconsts.chunk_size
  --print("Chunk Num "..tostring(chunk_num))
  --print("Chunk_idx "..tostring(chunk_idx))
  local len, base_data, nn_data = col:chunk(chunk_num)
  --TODO: check below condition if it is proper or not
  if len == nil or len == 0 then return 0 end
  if base_data == ffi.NULL then
    val = ffi.NULL
  else
    local qtype = col:qtype()
    local casted = get_ptr(base_data, qtype)
    if qtype == "B1" then
      local bit_value = tonumber( qc.get_bit_u64(casted, chunk_idx) )
      if bit_value == 0 then
         val = ffi.NULL
      else
         val = 1
      end
    else
      val = casted[chunk_idx]
    end
            
    -- to check if LL is present and then remove LL appended at end of I8 number
    if ( qtype == "I8" ) then
      val = tostring(val)
      local index1, index2 = string.find(val,"LL")
      local string_length = #val
      if index1 == string_length-1 and index2 == string_length then
        val = string.sub(val, 1, -3) 
      end
      val = tonumber(val)
    elseif ( qtype == "SC" ) then
      val = ffi.string(casted + chunk_idx * col:field_width())
    elseif ( qtype == "SV" ) then 
      --print("Index: "..tostring(val))
      local dictionary = col:get_meta("dir")
      val = dictionary:get_string_by_index(tonumber(val))
      --print("Value: "..tostring(val))
    end

    -- Check for nn vector
    if nn_data then
      local nn_casted = get_ptr(nn_data, "B1")
      local bit_value = tonumber( qc.get_bit_u64(nn_casted, chunk_idx) )
      if bit_value == 0 then
         nn_val = ffi.NULL
         val = ffi.NULL
      else
         nn_val = 1
      end    
    end
  end
  --print("Returning "..tostring(val).." ==== " ..tostring(nn_val))  
  return val, nn_val
end
