local get_num_cols = require 'Q/OPERATORS/PRINT_CSV/lua/get_num_cols'

local function chk_cols(vector_list)
  assert(vector_list)
  assert(type(vector_list) == "table")
  assert(get_num_cols(vector_list) > 0)
  -- assert(utils.table_length(vector_list) > 0)  
  local vec_length = nil
  local is_first = true
  for i, v in pairs(vector_list) do
    -- Check the vector for eval(), if not then call eval()
    if not v:is_eov() then
      v:eval()
    end

    -- eval'ed the vector before calling lenght()
    -- as elements will populate only after eval()
    if is_first then
      vec_length = assert(v:length())
      is_first = false
    end
    assert(type(vec_length) == "number")

    -- Added below assert after discussion with Ramesh
    -- We are not supporting vectors with different length as this is a rare case
    -- All vectors should have same length
    assert(v:length() == vec_length, "All vectors should have same length")
    assert(v:length() > 0)
    local qtype = v:qtype()
    assert(qconsts.qtypes[qtype], err.INVALID_COLUMN_TYPE)

    -- dictionary cannot be null in get_meta for SV data type
    if qtype == "SV" then
      assert(v:get_meta("dir"), err.NULL_DICTIONARY_ERROR)
    end
  end
  return true
end
