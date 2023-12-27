local cutils   = require 'libcutils'
local lgutils  = require 'liblgutils'
local cVector  = require 'libvctr'
local basic_serialize = require 'Q/UTILS/lua/basic_serialize'
local should_save = require 'Q/UTILS/lua/should_save'

-- skip_save() tells us whether saving of this vector should be skipped
local function skip_save(vec)
  -- TODO P4 At some point, we might want to relax following
  local num_elements = vec:num_elements()
  local has_gen      = vec:has_gen() 
  local is_eov       = vec:is_eov() 
  local is_error       = vec:is_error() 
  local memo_len     = vec:memo_len() 

  assert(type(num_elements) == "number")
  assert(type(has_gen)      == "boolean")
  assert(type(is_eov)       == "boolean")
  assert(type(is_error)       == "boolean")
  assert(type(memo_len)     == "number")

  if ( ( num_elements == 0 ) or ( memo_len >= 0 ) or 
    ( has_gen ) or ( not is_eov ) or ( is_error ) ) then
    return true
  else
    return false
  end
end

-- TODO Indrajeet make 2 args, one is name of table, other is filename
-- function internal_save(name, value, saved)
local function internal_save(
  depth, 
  name,
  value,
  Tsaved,
  fp
  )
  if not should_save(name, value) then return end
  print("Internal save of " .. name .. " at depth " .. depth)
  assert(type(Tsaved) == "table")
  assert(type(depth) == "number")
  assert(depth >= 0)
  assert(type(name) == "string")
  assert(#name > 0)
  --=======================================
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
        internal_save(depth+1, fieldname, v, Tsaved, fp)
      end
    end
  elseif ( type(value) == "lVector" ) then
    local vec = value
    local is_skip = skip_save(vec) 
     if ( is_skip ) then -- skip ths vector
      print("Not saving lVector: " .. name )
      -- print(vec:num_elements())
      -- print(vec:has_gen() ) 
      -- print(vec:is_eov() )
      -- print(vec:memo_len() )
    else
      -- flush vector to disk and mark for persistence
      vec:make_mem(2) -- copy from level 1 to level 2 
      print("Saving " .. vec:name())
      vec:persist()  -- indicate not to free level 2 upon delete
      fp:write(name, " = lVector ( { uqid = ", vec:uqid(), " } )\n" )
      -- repeat above for nn vector assuming it exists
      if ( vec:has_nulls() ) then
        local nn_vec  = vec:get_nulls()
        local nn_uqid = nn_vec:uqid()
        nn_vec:make_mem(2) 
        nn_vec:persist()  
        local nn_name = "_nn_" .. tostring(nn_uqid)
        fp:write("local " .. nn_name, " = lVector({uqid = ",nn_uqid,"})\n" )
        fp:write(name, ":set_nulls(" .. nn_name .. ")\n")
      end
    end
  elseif ( type(value) == "Scalar" ) then
    local sclr = value
    local scalar_str = sclr:reincarnate()
    assert(type(scalar_str) == "string")
    fp:write(name .. " = " .. scalar_str)
    fp:write("\n")
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
  -- print("Writing to ", meta_file)
  -- print("Writing to ", aux_file)
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
    internal_save(0, k, v, Tsaved, fp); -- print("Saving ", k, v)
  end
  fp:close()
  lgutils.save_session() -- saves data structures from C side 
  return meta_file
end
return require('Q/q_export').export('save', save)
