-- This version supports chunking in load_csv
local qconsts = require 'Q/UTILS/lua/q_consts'
local err     = require 'Q/UTILS/lua/error_code'
local qc            = require 'Q/UTILS/lua/q_core'
  
local function validate_meta(
  M -- meta data table 
)
  assert(type(M) == "table", err.METADATA_TYPE_TABLE)
  local col_names = {}
  -- now look at fields of metadata
  local num_cols_to_load = 0
  for midx, fld_M in pairs(M) do
    local col = "Column " .. midx .. "-"
    assert(type(fld_M) == "table", col .. err.COLUMN_DESC_ERROR)
    assert(fld_M.name,  col .. err.METADATA_NAME_NULL)
    local qtype = assert(fld_M.qtype, col .. err.METADATA_TYPE_NULL)
    assert(qconsts.qtypes[qtype], col ..  err.INVALID_QTYPE)
    --===========================================
    if fld_M.is_memo ~= nil then 
      assert(type(fld_M.is_memo) == "boolean")
    else
      fld_M.is_memo = true
    end
    --===========================================
    if fld_M.has_nulls ~= nil then 
      assert(type(fld_M.has_nulls) == "boolean",
        col .. err.INVALID_NN_BOOL_VALUE )
    else
      fld_M.has_nulls = false
    end
    -- Note special case for SC
    if ( qtype == "SC" ) then
      fld_M.has_nulls = false
    end
    --===========================================
    if fld_M.is_load ~= nil then 
      assert( type(fld_M.is_load) == "boolean",
        col .. err.IS_LOAD_BOOL_ERROR )
    else
      fld_M.is_load = true
    end
    --===========================================
    if ( fld_M.is_load ) then 
      -- Check uniqueness of field names: 
      assert(not col_names[fld_M.name], col .. err.DUPLICATE_COL_NAME) 
      col_names[fld_M.name] = true 
      num_cols_to_load = num_cols_to_load + 1
    end
    --===========================================
    local width -- how many bytes to allocate per element
    if qtype == "SC" then 
      width = assert(fld_M.width, err.MAX_WIDTH_NULL_ERROR)
      -- remember 1 byte for nullc
      assert( ((width >= 2) and (width <= qconsts.max_width["SC"])), 
        col .. err.INVALID_WIDTH_SC )
    elseif fld_M.qtype == "B1" then 
      width = 1
    else
      width = assert(qconsts.qtypes[qtype].width)
    end
    fld_M.width = width
    --===========================================
  end
  assert(num_cols_to_load > 0, err.COLUMN_NOT_PRESENT)
  return true
end
return validate_meta
