-- This version supports chunking in load_csv
local cutils = require 'libcutils'
local qc      = require 'Q/UTILS/lua/qcore'
local qcfg    = require 'Q/UTILS/lua/qcfg'
  
local function validate_meta(
  M -- meta data table 
)
  assert(type(M) == "table")
  -- this table must be indexed as 1, 2 . ...
  -- That is beacuse the indexes represent the position in the CSV file
  local cnt = 0
  for _, v in pairs(M) do cnt = cnt + 1 end
  assert(cnt == #M) 
  local col_names = {} -- names of columns to load 
  -- now look at fields of metadata
  local num_cols_to_load = 0
  for _, fld_M in ipairs(M) do
    assert(type(fld_M) == "table")
    local name = assert(fld_M.name)
    assert(type(name) == "string")
    local qtype = assert(fld_M.qtype)
    assert(type(qtype) == "string")
    assert(cutils.is_qtype(qtype))
    --===========================================
    if fld_M.is_persist ~= nil then 
      assert(type(fld_M.is_persist) == "boolean")
    else
      fld_M.is_persist = false
    end
    --===========================================
    if fld_M.nn_qtype ~= nil then 
      error("Cannot set nn_qtype per field")
    end
    --===========================================
    if fld_M.is_memo ~= nil then 
      assert(type(fld_M.is_memo) == "boolean")
    else
      fld_M.is_memo = true
    end
    --===========================================
    -- Default assumption is that fields do NOT have null values
    if fld_M.has_nulls ~= nil then 
      assert(type(fld_M.has_nulls) == "boolean")
    else
      fld_M.has_nulls = false
    end
    -- Note special case for SC
    if ( qtype == "SC" ) then
      fld_M.has_nulls = false
    end
    --===========================================
    if fld_M.is_load ~= nil then 
      assert(type(fld_M.is_load) == "boolean")
    else
      fld_M.is_load = true
    end
    --===========================================
    if ( fld_M.is_load ) then 
      -- Check uniqueness of field names: 
      assert(not col_names[fld_M.name], "field names not unique")
      col_names[fld_M.name] = true 
      num_cols_to_load = num_cols_to_load + 1
    end
    --===========================================
    if ( fld_M.meaning ) then 
      assert(type(fld_M.meaning) == "string")
    end
    --===========================================
    local width -- how many bytes to allocate per element
    if qtype == "SC" then 
      -- remember 1 byte for nullc
      width = assert(fld_M.width)
      assert(type(width) ==  "number")
      assert(width >= 2)
      assert(width <= qcfg.max_width_SC)
    elseif fld_M.qtype == "B1" then 
      width = 1
    else
      width = assert(cutils.get_width_qtype(qtype))
    end
    fld_M.width = width
    --===========================================
  end
  assert(num_cols_to_load > 0)
  return true
end
return validate_meta
