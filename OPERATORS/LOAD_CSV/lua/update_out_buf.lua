local err           = require 'Q/UTILS/lua/error_code'
local qc            = require 'Q/UTILS/lua/q_core'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local ffi           = require 'Q/UTILS/lua/q_ffi'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'

local function update_out_buf(
  in_buf,
  m,  -- m is meta data for field
  d,  -- d is dictiomnary for field
  out_buf,
  num_in_out_buf, 
  n_buf
  )
  local status = 0
  -- local in_buf_len = assert(tonumber(ffi.C.strlen(in_buf)))
  if m.qtype == "SV" then
    local in_buf_len = tonumber(ffi.C.strlen(in_buf))
    assert(in_buf_len <= m.max_width, err.STRING_TOO_LONG)
    local stridx = nil
    if ( in_buf_len == 0 ) then
      stridx = 0
    else
      if ( m.add ) then
        stridx = d:add(ffi.string(in_buf))
      else
        stridx = d:get_index_by_string(ffi.string(in_buf))
      end
    end
    assert(stridx, "dictionary does not have string " .. ffi.string(in_buf))
    -- Notice that SV is stored as I4
    ffi.cast(qconsts.qtypes.I4.ctype .. " *", out_buf)[num_in_out_buf] = stridx
    --=================================================
  elseif m.qtype == "SC" then
    local in_buf_len = tonumber(ffi.C.strlen(in_buf))
    assert(in_buf_len <= m.width, err.STRING_TOO_LONG)
    local ctype = assert(qconsts.qtypes[m.qtype]["ctype"])
    out_buf = ffi.cast(ctype .. " *", out_buf)
    out_buf = out_buf + num_in_out_buf * m.width
    ffi.copy(out_buf, in_buf, in_buf_len)
    --=================================================
  elseif is_base_qtype(m.qtype) then
    local converter = assert(qconsts.qtypes[m.qtype]["txt_to_ctype"])
    local ctype     = assert(qconsts.qtypes[m.qtype]["ctype"])
    local width     = assert(qconsts.qtypes[m.qtype]["width"])
    out_buf    = ffi.cast(ctype .. " *", out_buf)
    out_buf = out_buf + num_in_out_buf
    status = qc[converter](in_buf, out_buf)
    --=================================================
  elseif m.qtype == "B1" then  -- IMPROVE THIS CODE

    -- Update out_buf for B1
    local temp_B1_out_buf = ffi.cast(qconsts.qtypes.B1.ctype .. " *", out_buf)
    local in_val = tonumber(ffi.string(in_buf))
    assert(in_val ~= 0 or in_val ~= 1, "Not a proper B1 value " .. ffi.string(in_buf))
    qc.set_bit_u64(temp_B1_out_buf, num_in_out_buf, in_val)
  else
    assert(nil, "Unknown type " .. m.qtype)
  end
  assert(status == 0, err.INVALID_DATA_ERROR .. m.qtype)
end
return update_out_buf

