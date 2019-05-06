require 'globals'
local g_err = require 'error_code'
local pl = require 'pl'
local plpath = require 'pl.path'
  
return function (
  M -- meta data table 
)
  assert(type(M) == "table", g_err.METADATA_TYPE_TABLE)
  assert(plpath.isdir(_G["Q_META_DATA_DIR"]), g_err.Q_META_DATA_DIR_INCORRECT)
  
  local col_names = {}
  -- now look at fields of metadata
  local num_cols_to_load = 0
  for midx, fld_M in pairs(M) do
    local col = "Column " .. midx .. "-"
    assert(type(fld_M) == "table", col .. g_err.COLUMN_DESC_ERROR)
    assert(fld_M.name,  col .. g_err.METADATA_NAME_NULL)
    assert(fld_M.qtype, col .. g_err.METADATA_TYPE_NULL)
    assert(g_qtypes[fld_M.qtype], col ..  g_err.INVALID_QTYPE)
    if fld_M.has_nulls ~= nil then 
      assert((fld_M.has_nulls == true  or fld_M.has_nulls == false ), col .. g_err.INVALID_NN_BOOL_VALUE )
    else
      fld_M.has_nulls = false
    end
    if fld_M.is_load ~= nil then 
      assert((fld_M.is_load == true  or fld_M.is_load == false ), 
      col .. g_err.IS_LOAD_BOOL_ERROR )
    else
      fld_M.is_load = true
    end
    if ( fld_M.is_load ) then 
      assert(not col_names[fld_M.name],
      col .. g_err.DUPLICATE_COL_NAME) 
      col_names[fld_M.name] = true 
      num_cols_to_load = num_cols_to_load + 1
    end
    if fld_M.qtype == "SC" then 
      assert(fld_M.width ~=nil , g_err.MAX_WIDTH_NULL_ERROR)
      assert((tonumber(fld_M.width) >= 2) and (tonumber(fld_M.width) <= g_max_width_SC), col .. g_err.INVALID_WIDTH_SC ) 
    end
    if fld_M.qtype == "SV" then
      --print(fld_M.max)
      assert(fld_M.max_width ~=nil , g_err.MAX_WIDTH_NULL_ERROR)
      assert(((fld_M.max_width >= 2) and (fld_M.max_width <= g_max_width_SV)), col .. g_err.INVALID_WIDTH_SV )
      
      assert(fld_M.dict, col .. g_err.DICTIONARY_NOT_PRESENT)

      assert(fld_M.is_dict ~= nil, col .. g_err.IS_DICT_NULL) 
      
      assert(fld_M.is_dict == true or fld_M.is_dict == false, 
      col .. g_err.INVALID_IS_DICT_BOOL_VALUE)

      if fld_M.is_dict == true then 
        -- TODO Verify that dictionary exists
        assert(fld_M.add == true or fld_M.add == false, 
        col .. g_err.INVALID_ADD_BOOL_VALUE)
      else
        fld_M.add = true
      end
      -- TODO  everybodu can add to a dict or nobody can add to it 
      --
    end
  end
  assert(num_cols_to_load > 0, g_err.COLUMN_NOT_PRESENT)
  return true
end
