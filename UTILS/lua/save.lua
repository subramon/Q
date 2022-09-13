local cutils   = require 'libcutils'
local lgutils  = require 'liblgutils'
local cVector  = require 'libvctr'
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
    local vec = value
    -- TODO P4 At some point, we might want to relax following
    if ( ( vec:num_elements() == 0 ) or ( vec:has_gen() ) 
        or ( vec:is_eov() == false ) ) then
      -- skip ths vector
      print("Not saving lVector" .. name )
    else
      -- flush vector to disk and mark for persistence
      vec:l1_to_l2()
      vec:persist()
      fp:write(name, " = lVector ( ", vec:uqid(), " )\n" )
    end
  elseif ( type(value) == "Scalar" ) then
    local sclr = value
    local scalar_str = sclr:reincarnate()
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

local function save()
  local meta_dir = lgutils.meta_dir()
  assert(type(meta_dir) == "string")
  assert(cutils.isdir(meta_dir))
  local meta_file = meta_dir .. "/q_meta.lua" -- note .lua suffix
  local aux_file  = meta_dir .. "/q_aux.lua"

  if  cutils.isfile(meta_file) or  cutils.isfile(aux_file) then
    print("Warning! Over-writing meta data file ", meta_file)
    print("Warning! Over-writing aux data file ", aux_file)
    cutils.delete(meta_file)
    cutils.delete(aux_file)
  end
  print("Writing to ", meta_file)
  print("Writing to ", aux_file)
  --================================================
  local fp = assert(io.open(aux_file, "w+"))
  local str = string.format("status = %s", "TODO")
  fp:write(str)
  fp:close()
  --================================================
  fp = assert(io.open(meta_file, "w+"))
  fp:write("local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'\n")
  fp:write("local cVector = require 'libvctr'\n")
  fp:write("local Scalar  = require 'libsclr'\n")
  -- NEEDED ?? fp:write("local cmem    = require 'libcmem'\n")
  -- NEEDED ?? fp:write("local cutils  = require 'libcutils'\n")

  -- saved is a table that keeps track of things we have already saved
  -- so that we don't save them a second time around
  -- TODO But why exactly is it needed?
  local Tsaved = {}
  -- For all globals,
  for k, v in pairs(_G) do
    internal_save(k, v, Tsaved, fp); -- print("Saving ", k, v)
  end
  fp:close()
  return meta_file
end
return require('Q/q_export').export('save', save)
