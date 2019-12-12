local ffi     = require 'ffi'
local cutils  = require 'libcutils'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc = ffi.load('libq_core')

local basic_serialize = require 'Q/UTILS/lua/basic_serialize'
local should_save = require 'Q/UTILS/lua/should_save'

-- TODO Indrajeet make 2 args, one is name of table, other is filename
-- function internal_save(name, value, saved)
local function internal_save(
  name, 
  value, 
  saved, 
  file
  )
  saved = saved or {} -- initial value
  file = file or io   -- if no file provided, write to stdout
  if ( ( type(value) == "number" ) or 
       ( type(value) == "string" ) or 
       ( type(value) == "boolean" ) ) then
    file:write(name, " = ")
    file:write(basic_serialize(value), "\n")
  elseif type(value) == "table" then
    local tbl = value
    file:write(name, " = ")
    if saved[tbl] then    -- value already saved?
      file:write(saved[tbl], "\n")  -- use its previous name
    else
      saved[tbl] = name   -- save name for next time
      file:write("{}\n")     -- create a new table
      for k, v in pairs(tbl) do      -- save its fields
        local fieldname = string.format("%s[%s]", name, basic_serialize(k))
        internal_save(fieldname, v, saved, file)
      end
    end
  elseif ( type(value) == "lVector" ) then 
    local persist_str = value:reincarnate()
    if ( persist_str ) then 
      file:write(name, " = ")
      file:write(persist_str)
      file:write("\n")
      internal_save(name .. "._meta", value._meta, saved, file)
      file:write(name .. ":persist(true)")
      file:write("\n")
    else
      print("Not saving lVector because eov=false or is_memo=false ", name)
    end
  elseif ( type(value) == "Scalar" ) then
    local scalar_str = value:reincarnate()
    file:write(name .. " = " .. scalar_str)
    file:write("\n")
  elseif ( type(value) == "lAggregator" ) then
    print("Serialization of Aggregators not supported as yet"); -- TODO P2
  elseif ( type(value) == "lDNN" ) then
    print("Serialization of DNNs not supported as yet"); -- TODO P2
  elseif ( type(value) == "lDictionary" ) then
    -- TODO Need to fix this 
    local scalar_str = value:reincarnate()
    file:write(name .. " = " .. scalar_str)
    file:write("\n")
  else
    error("cannot save " .. name .. " of type " .. type(value))
  end
end

local function save(file_to_save)
  
  -- Decide on where you are going to write the output
  local metadata_file
  if ( file_to_save ) then 
    metadata_file = file_to_save
  else
    metadata_file = qconsts.Q_METADATA_FILE
  end
  assert(type(metadata_file) == "string")
  if  cutils.isfile(metadata_file) then 
    print("Warning! Over-writing meta data file ", metadata_file)
  end
  local fp = assert(io.open(metadata_file, "w+"), 
    "Unable to open file for writing" .. metadata_file)
  --================================================
  fp:write("local lVector     = require 'Q/RUNTIME/lua/lVector'\n")
  -- TODO P1 Eliminate lDictionary
  fp:write("local lDictionary = require 'Q/RUNTIME/lua/lDictionary'\n")
  fp:write("local lAggregator = require 'Q/RUNTIME/AGG/lua/lAggregator'\n")
  -- TODO Confirm that we need all these guys below
  fp:write("local lDNN         = require 'Q/RUNTIME/DNN/lua/lDNN'\n")
  fp:write("local Scalar      = require 'libsclr'\n")
  fp:write("local cmem        = require 'libcmem'\n")

  -- saved is a table that keeps track of things we have alreday saved
  -- so that we don't save them a second time around
  -- TODO But why exactly is it needed?
  local saved = {}
  -- For all globals,
  for k,v in pairs(_G) do
    if should_save(k, v) then
      internal_save(k, v, saved, fp); -- print("Saving ", k, v)
    end
  end
  fp:close()
  print("Saved to " .. metadata_file)
  return metadata_file
end
return require('Q/q_export').export('save', save)
