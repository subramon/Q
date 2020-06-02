local cutils  = require 'libcutils'
local qconsts = require 'Q/UTILS/lua/q_consts'
-- TO DELETE local ffi     = require 'ffi'
-- TO DELETE local qc = ffi.load('libq_core')

local basic_serialize = require 'Q/UTILS/lua/basic_serialize'
local should_save = require 'Q/UTILS/lua/should_save'

-- TODO Indrajeet make 2 args, one is name of table, other is filename
-- function internal_save(name, value, saved)
local function internal_save(
  name, 
  value, 
  Tsaved, 
  fp
  )
  if not should_save(name, value) then return end 
  assert(type(Tsaved) == "table")
  if ( ( type(value) == "number" ) or 
       ( type(value) == "string" ) or 
       ( type(value) == "boolean" ) ) then
    fp:write(name, " = ")
    fp:write(basic_serialize(value), "\n")
  elseif type(value) == "table" then
    local tbl = value
    fp:write(name, " = ")
    if Tsaved[tbl] then    -- value already saved?
      fp:write(Tsaved[tbl], "\n")  -- use its previous name
    else
      Tsaved[tbl] = name   -- save name for next time
      fp:write("{}\n")     -- create a new table
      for k, v in pairs(tbl) do      -- save its fields
        local fieldname = string.format("%s[%s]", name, basic_serialize(k))
        internal_save(fieldname, v, Tsaved, fp)
      end
    end
  elseif ( type(value) == "lVector" ) then 
    local vector_str = value:reincarnate()
    if ( vector_str ) then 
      fp:write(name, " = ")
      fp:write(vector_str)
      fp:write("\n")
      --===========================
      internal_save(name .. "._meta", value._meta, saved, fp)
      fp:write(name .. ":persist(true)")
      fp:write("\n")
    else
      print("Not saving lVector because eov=false or is_memo=false ", name)
    end
  elseif ( type(value) == "Scalar" ) then
    local scalar_str = value:reincarnate()
    assert(type(scalar_str) == "string")
    fp:write(name .. " = " .. scalar_str)
    fp:write("\n")
  elseif ( type(value) == "lAggregator" ) then
    print("Serialization of Aggregators not supported as yet"); -- TODO P2
  elseif ( type(value) == "lDNN" ) then
    print("Serialization of DNNs not supported as yet"); -- TODO P2
  else
    error("cannot save " .. name .. " of type " .. type(value))
  end
end

local function save(outfile)
  -- Decide on where you are going to write the output
  local metadata_file
  if ( outfile ) then 
    metadata_file = outfile
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
  fp:write("local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'\n")
  fp:write("local cVector = require 'libvctr'\n")
  fp:write("local Scalar  = require 'libsclr'\n")
  fp:write("local cmem    = require 'libcmem'\n")
  fp:write("local cmem    = require 'libcutils'\n")

  -- saved is a table that keeps track of things we have already saved
  -- so that we don't save them a second time around
  -- TODO But why exactly is it needed?
  local Tsaved = {}
  -- For all globals,
  for k, v in pairs(_G) do
    internal_save(k, v, Tsaved, fp); -- print("Saving ", k, v)
  end
  fp:close()
  print("Saved to " .. metadata_file)
  return metadata_file
end
return require('Q/q_export').export('save', save)
