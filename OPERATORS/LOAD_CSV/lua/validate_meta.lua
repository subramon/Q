local qconsts = require 'Q/UTILS/lua/q_consts'
local err     = require 'Q/UTILS/lua/error_code'
local qc            = require 'Q/UTILS/lua/q_core'
  
local function validate_meta(
  M -- meta data table 
)
  assert(type(M) == "table", err.METADATA_TYPE_TABLE)
-- Sri: this should be ensured by library loading; trust our own
--  assert(qc["isdir"](_G["Q_META_DATA_DIR"]), err.Q_META_DATA_DIR_INCORRECT)
  
  local col_names = {}
  -- now look at fields of metadata
  local num_cols_to_load = 0
  for midx, fld_M in pairs(M) do
    local col = "Column " .. midx .. "-"
    assert(type(fld_M) == "table", col .. err.COLUMN_DESC_ERROR)
    assert(fld_M.name,  col .. err.METADATA_NAME_NULL)
    assert(fld_M.qtype, col .. err.METADATA_TYPE_NULL)
    assert(fld_M.qtype, col .. err.METADATA_TYPE_NULL)
    assert(qconsts.qtypes[fld_M.qtype], col ..  err.INVALID_QTYPE)
    --===========================================
    if fld_M.is_memo ~= nil then 
      assert(type(fld_M.is_memo) == "boolean")
    else
      fld_M.is_memo = true
    end
    --===========================================
    if fld_M.has_nulls ~= nil then 
      assert((fld_M.has_nulls == true  or fld_M.has_nulls == false ), col .. err.INVALID_NN_BOOL_VALUE )
    else
      fld_M.has_nulls = false
    end
    --===========================================
    if fld_M.is_load ~= nil then 
      assert((fld_M.is_load == true  or fld_M.is_load == false ), 
      col .. err.IS_LOAD_BOOL_ERROR )
    else
      fld_M.is_load = true
    end
    --===========================================
    if ( fld_M.is_load ) then 
      assert(not col_names[fld_M.name],
      col .. err.DUPLICATE_COL_NAME) 
      col_names[fld_M.name] = true 
      num_cols_to_load = num_cols_to_load + 1
    end
    --===========================================
    if fld_M.qtype == "SC" then 
      assert(fld_M.width ~=nil , err.MAX_WIDTH_NULL_ERROR)
      assert((tonumber(fld_M.width) >= 2) and (tonumber(fld_M.width) <= qconsts.max_width["SC"]), col .. err.INVALID_WIDTH_SC )
      if fld_M.convert_sc ~= nil then
          assert((fld_M.convert_sc == true or fld_M.convert_sc == false),
          "convert_sc meta field not of type boolean" )
      else
        -- TODO: default value for convert_sc
        fld_M.convert_sc = false
      end
    end
    --===========================================
    if fld_M.qtype == "SV" then
      --print(fld_M.max)
      assert(fld_M.max_width ~=nil , err.MAX_WIDTH_NULL_ERROR)
      assert(((fld_M.max_width >= 2) and (fld_M.max_width <= qconsts.max_width["SV"])), col .. err.INVALID_WIDTH_SV )
      
      assert(fld_M.dict, col .. err.DICTIONARY_NOT_PRESENT)

      assert(fld_M.is_dict ~= nil, col .. err.IS_DICT_NULL) 
      
      assert(fld_M.is_dict == true or fld_M.is_dict == false, 
      col .. err.INVALID_IS_DICT_BOOL_VALUE)

      if fld_M.is_dict == true then 
        -- TODO Verify that dictionary exists
        assert(fld_M.add == true or fld_M.add == false, 
        col .. err.INVALID_ADD_BOOL_VALUE)
      else
        fld_M.add = true
      end
      -- TODO  everybodu can add to a dict or nobody can add to it 
      --
    end
  end
  assert(num_cols_to_load > 0, err.COLUMN_NOT_PRESENT)
  return true
end
return validate_meta
