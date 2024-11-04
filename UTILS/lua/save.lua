local cutils   = require 'libcutils'
local lgutils  = require 'liblgutils'
local cVector  = require 'libvctr'
local basic_serialize = require 'Q/UTILS/lua/basic_serialize'
local should_save = require 'Q/UTILS/lua/should_save'
local ifxthenyelsez = require 'Q/UTILS/lua/ifxthenyelsez'

-- skip_save() tells us whether saving of this vector should be skipped
local function skip_save(vec)
  local is_dead = false
  local is_skip = false
  -- TODO P4 At some point, we might want to relax following
  local num_elements = vec:num_elements()
  if ( num_elements == nil ) then
    print("Being asked to save a Vector that does not exist. Skipping...")
    is_dead = true
    return true, is_dead
  end
  local has_gen              = vec:has_gen() 
  local is_eov               = vec:is_eov() 
  local is_error             = vec:is_error() 
  local is_early_freeable, _ = vec:get_early_freeable() 
  local is_killable, _       = vec:get_killable() 
  local memo_len, _          = vec:get_memo() 
  local is_nn_vec            = vec:is_nn_vec() 

  assert(type(num_elements)      == "number")
  assert(type(has_gen)           == "boolean")
  assert(type(is_eov)            == "boolean")
  assert(type(is_error)          == "boolean")
  assert(memo_len                >= 0)
  assert(type(is_early_freeable) == "boolean")
  assert(type(is_killable)       == "boolean")
  assert(type(is_nn_vec)       == "boolean")

  local reason = "none"
  if ( num_elements == 0 ) then reason = "empty vector" end 
  if ( has_gen           ) then reason = "has generator " end 
  if ( is_eov            ) then reason = "eov == true " end 
  if ( is_error          ) then reason = "error == true " end 
  if ( is_memo           ) then reason = "is_memo == true " end 
  if ( is_early_freeable ) then reason = "is_early_freeable == true " end 
  if ( is_killable       ) then reason = "is_killable == true " end 
  if ( is_nn_vec         ) then reason = "is_nn_vec == true " end 
  if ( 
    ( num_elements == 0 ) or ( is_memo ) or 
    ( has_gen ) or ( not is_eov ) or ( is_error ) or
    ( is_early_freeable ) or ( is_killable ) or ( is_nn_vec ) 
    ) then
    print("Not saving Vector " .. 
    ifxthenyelsez(vec:name(), "anonymous_" .. vec:uqid()) .. 
    " because " .. reason)


    is_skip = true 
  else
    print("Saving Vector     " .. (vec:name() or "anonymous"))
    is_skip = false 
  end
  return is_skip, is_dead
end

-- TODO Indrajeet make 2 args, one is name of table, other is filename
-- function internal_save(name, value, saved)
local function internal_save(
  depth, 
  name,
  value,
  Tsaved,
  fp,
  uqid_to_vecs
  )
  if not should_save(name, value) then return end
  -- print("Internal save of " .. name .. " at depth " .. depth)
  assert(type(Tsaved) == "table")
  assert(type(depth) == "number")
  assert(depth >= 0)
  assert(type(name) == "string")
  assert(#name > 0)
  assert(type(uqid_to_vecs) == "table")
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
        internal_save(depth+1, fieldname, v, Tsaved, fp, uqid_to_vecs)
      end
    end
  elseif ( type(value) == "lVector" ) then
    local vec = value
    local is_skip, is_dead = skip_save(vec) 
     if ( is_skip ) then -- skip ths vector
       if ( is_dead ) then
         print("Problem with dead vector")
       else
        -- print("Not saving lVector: " .. vec:name())
        -- TODO P2 Think. Is following delete() needed?
        vec:delete() -- Delete this vector from hashmaps
      end
    else
      -- flush vector to disk and mark for persistence
      if ( not vec:is_lma() ) then 
        vec:make_mem(2) -- copy from level 1 to level 2 
      end
      -- print("Saving [" .. vec:name() .. "]")
      vec:persist()  -- indicate not to free level 2 upon delete
      local uqid = vec:uqid()
      local rand_name = uqid_to_vecs[uqid] 
      if ( rand_name ) then 
        fp:write(name, " =  ", rand_name, "\n")
      else
        rand_name = cutils.rand_file_name()
        rand_name = string.gsub(rand_name, ".bin", "")
        fp:write("local ", rand_name, 
          " = lVector ( { tbsp = 0, uqid = ", vec:uqid(), " } )\n" )
        -- Note the tbsp = 0. One may wonder why this is here given
        -- that that is the default value. The reason is that it makes
        -- it easy for us to modify the meta file to change 
        -- tbsp = 0 to tbsp = 23 
        -- when somebody else is importing the vectors being saved here
        fp:write(name, " =  ", rand_name, "\n")
        uqid_to_vecs[uqid] = rand_name
      end
      -- repeat above for nn vector assuming it exists
      if ( vec:has_nulls() ) then
        local nn_vec  = vec:get_nn_vec()
        if ( not nn_vec:is_lma() ) then 
          nn_vec:make_mem(2) 
        end
        nn_vec:persist()  
        local nn_uqid = nn_vec:uqid()
        local rand_name = uqid_to_vecs[uqid] 
        if ( rand_name ) then
          -- nothing todo 
        else
          rand_name = cutils.rand_file_name()
          rand_name = string.gsub(rand_name, ".bin", "")
          fp:write("local ", rand_name, 
            " = lVector ( { uqid = ", nn_uqid, " } )\n" )
          fp:write(name, " =  ", rand_name, "\n")
          uqid_to_vecs[nn_uqid] = rand_name
        end
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
  collectgarbage()
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
  local uqid_to_vecs = {}-- given a uqid, returns the vector that has been created with this uqid 
  fp = assert(io.open(meta_file, "w+"))
  fp:write("do\n"); -- open a scope 
  fp:write("local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'\n")
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
    internal_save(0, k, v, Tsaved, fp, uqid_to_vecs); -- print("Saving ", k, v)
  end
  fp:write("end\n"); -- close the scope
  fp:close()
  lgutils.save_session() -- saves data structures from C side 
  print("Completed save")
  return meta_file
end
return require('Q/q_export').export('save', save)
