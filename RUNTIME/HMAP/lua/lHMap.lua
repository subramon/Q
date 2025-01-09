-- How to create a hashmap in Q using RSHMAP/fixed_len_kv/
-- Follows pattern of VCTR/lua/lVector.lua and VCTR/src/cHMap.c 

local ffi     = require 'ffi'
local cutils  = require 'libcutils'
local qcfg    = require'Q/UTILS/lua/qcfg'

local register_type = require 'RSUTILS/lua/register_type'
-- THINK code gen needed? local cHMap = require 'Q/RUNTIME/HMAP/src/libhmap'
--====================================
local lHMap = {}
lHMap.__index = lHMap

-- Following hack of __gc is needed because of inability to set
-- __gc on anything other than userdata in 5.1.* 
-- This is why we need cHMap.c and cannot directly ffi to the 
-- C files in ../src/
-- Given that we are paying the price of using the C API, I think
-- we can dispense with this __gc business
local setmetatable = require 'Q/UTILS/lua/rs_gc'
local mt = {
   __call = function (cls, ...)
      return cls.new(...)
   end,
   __gc = true
 }
setmetatable(lHMap, mt)

register_type(lHMap, "lHMap")

local function make_null_vec()
  return false
end

function lHMap:check()
  return true
end

-- START: Following about name 
function lHMap:name()
  local name = cHMap.name(self._base_vec)
  return name
end

function lHMap:set_name(name, nn_name)
  if ( name == nil ) then name = "" end 
  assert(type(name) == "string")
  assert(cHMap.set_name(self._base_vec, name))
  return self
end
-- STOP : Following about name 
-- START: Following about persist
function lHMap:persist()
  local status = cHMap.persist(self._base_vec)
  return self
end
function lHMap:is_persist()
  local b_is_persist = cHMap.is_persist(self._base_vec)
  assert(type(b_is_persist) == "boolean")
  return b_is_persist
end
-- STOP: Above about persist

--=================================================
function lHMap.new(args)
  local hmap = setmetatable({}, lHMap)
  hmap._is_dead = false -- will be set to true upon deletion
  assert(type(args) == "table")
  --=================================================
  if ( false )  then
    print("Rehydrating hashmap")
    return hmap 
  end
  local label = assert(args.label)
  assert(type(label) == "string")
  assert(#label > 1)
  if ( hmap_exists(label) ) then
  else
    print("Need to provide a directory which contains relevant files")
    local code_dir = assert(args.code_dir)
    assert(type(code_dir) == "string")
    assert(cutils.isdir(code_dir))
  end
  hmap._is_dead = false
  return hmap
end
--=======================================================
function lHMap:put1(key, val)
  assert(self._is_dead == false)
  assert(type(key) == "CMEM")
  assert(type(val) == "CMEM")
  return self
end
--=======================================================
function lHMap:reset_put_vec(keyvecs, valvecs)
  assert(self._is_dead == false)
  self._keyvecs = keyvecs
  self._valvecs = valvecs
  self._chnk_idx = 0
  self._num_put  = 0
  return self
end
--=======================================================
function lHMap:set_put_vec(keyvecs, valvecs)
  assert(self._is_dead == false)
  -- cannot set a put vector if one has been set or get vec has been set
  -- some syntactic sugar to allow single vecs to be passed as such
  if ( type(keyvecs) ~= "table" ) then keyvecs = { keyvecs } end 
  if ( type(valvecs) ~= "table" ) then valvecs = { valvecs } end 
  --=================
  for k, v in ipairs(valvecs) do assert(type(v) == "lVector") end 
  for k, v in ipairs(keyvecs) do assert(type(v) == "lVector") end 
  assert(#valvecs >= 1)
  assert(#keyvecs >= 1)
  --=================
  assert(not self._keyvecs)
  assert(not self._valvecs)
  self._keyvecs = keyvecs
  self._valvecs = valvecs
  self._chnk_idx = 0
  self._num_put  = 0
end
--=======================================================
function lHMap:put_chunk(chnk_idx)
  assert(self._is_dead == false)
  assert(type(chnk_idx) == "number")
  assert(self._keyvecs)
  assert(self._valvecs)
  assert(chnk_idx == self._chnk_idx)
  local n = 0
  --=======================================================
  local key_chunks = {}
  local key_width = ffi.new("uint32_t[?]", #self._keyvecs)
  local sum_key_width = 0
  for k, v in ipairs(self._keyvecs) do 
    key_width[k-1] = v:width(k)
    sum_key_width = sum_key_width + key_width[k-1] 
    local ln, x, nn_x = v:get_chunk(chnk_idx)
    -- all chunks have same length 
    if ( k == 1 ) then n = ln else assert(n == ln) end 
    assert(type(nn_x) == "nil") -- not handled just yet
    key_chunks[k] == x 
  end
  --=======================================================
  local val_chunks = {}
  local val_width = ffi.new("uint32_t[?]", #self._valvecs)
  for k, v in ipairs(self._valvecs) do 
    val_width[k-1] = v:width(k)
    sum_val_width = sum_val_width + val_width[k-1] 
    local ln, x, nn_x = v:get_chunk(chnk_idx)
    -- all chunks have same length 
    assert(n == ln) 
    assert(type(nn_x) == "nil") -- not handled just yet
    val_chunks[k] == x 
  end
  --=======================================================
  -- This is the tricky part: converting from column order to row order
  local key_cmem = assert(cmem.new(n * sum_key_width))
  local val_cmem = assert(cmem.new(n * sum_val_width))
  -- allocate space for column pointers
  local key_col_ptrs = ffi.new("void *[?]", #self._keyvecs)
  local val_col_ptrs = ffi.new("void *[?]", #self._valvecs)
  -- fill in column pointers
  for k, c in ipairs(key_chunks) do 
    key_col_ptrs[k-1] = get_ptr(c)-
  end
  for k, c in ipairs(val_chunks) do 
    val_col_ptrs[k-1] = get_ptr(c)-
  end
  --=======================================================
  assert(cutils.transpose(key_col_ptrs, key_width, key_offset, 
    #key_col_ptrs, n, key_cmem))
  assert(cutils.transpose(val_col_ptrs, val_width, key_offset, 
    #val_col_ptrs, n, val_cmem))
  --=== Iterate over each row in (key_cmem/val_cmem) and add it to hmap
  for i = 1, n do
    local ptr_key = get_ptr(key_cmem, "char *") + sum_key_width*(i-1)
    local ptr_val = get_ptr(val_cmem, "char *") + sum_val_width*(i-1)
    put(&hmap, ptr_key, ptr-val)
  end
  
  val_cmem:delete()
  key_cmem:delete()
end
--=======================================================
function lHMap:eval_put(keyvec, valvec)
  return self
end
--=======================================================
function lHMap:put_chunk(chnk, n, nn_chnk)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  -- cannot put into complete vector 
  assert(self:is_eov() == false) 
  -- cannot put into nn vector 
  assert(not cHMap.is_nn_vec(self._base_vec))
  --============
  assert(type(chnk) == "CMEM")
  assert(type(n) == "number")
  assert(n > 0) -- cannot put empty chunk 
  if ( nn_chnk ) then assert(type(nn_chnk) == "CMEM") end 
  --============
  local nn_vec
  local has_nn_vec = cHMap.has_nn_vec(self._base_vec)
  -- nn_col can be provided only of vector has nulls
  if ( nn_chnk ) then 
    -- assert(has_nn_vec == true)
    -- Above assert is too agressive. This situation happens
    -- when the vector is created with nulls but we decide 
    -- to drop the nulls after that e.g.
    -- w = Q.vveq(x, y) -- w will have nulls if x or y do
    -- But say we now do
    -- w:drop_nn_vec()
    -- when we do 
    -- v = Q.sum(w)
    -- we will get nn_chnks for w but we won't put it 
  end
  -- if vector has nulls, nn_chnk must be provided 
  -- if vector has nulls, nn vector must be of type BL
  if ( has_nn_vec ) then 
    nn_vec = assert(cHMap.get_nn_vec(self._base_vec))
    assert(nn_vec:qtype() == "BL") -- current limitation
  end 
  --=== Checks complete, ready to do work
  assert(cHMap.put_chunk(self._base_vec, chnk, n))
  if ( has_nn_vec ) then  
    assert(cHMap.put_chunk(nn_vec, nn_chnk, n))
  else
    if ( type(nn_chnk) == "CMEM" ) then
      --[[ this can happen if we have dropped_nulls for this vector.
      Suppose we did x = Q.vvor(y, z) where y and z have nulls
      and then we did x:drop_nn_vec()
      but the vvor will return a nn_chunk for x 
      --]]
      nn_chnk:delete() -- not needed
    end
  end
end

function lHMap:pr(opfile, lb, ub, format)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  assert(cHMap.pr(self._base_vec, nn_vec, opfile, lb, ub, format))
  return true
end
--========================================================
lHMap.__gc = function (vec)
  if ( vec._is_dead ) then
    -- print("Vector already dead.")
    return false
  end 
  if ( cHMap.is(vec._base_vec) ) then 
    local vname = ifxthenyelsez(vec:name(), "anonymous_" .. vec:uqid())
    -- print("GC CALLED on " .. tostring(vec:uqid()) .. " -> " .. vname)
  else
    return true -- already deleted 
  end
  --=========================================
  --[[ Not needed because done on C side 
  if ( vec:has_nn_vec() ) then 
    local nn_vec = cHMap.get_nn_vec(self._base_vec)
    cHMap.delete(nn_vec)
  end
  --]]
  if ( cHMap.has_parent(vec._base_vec) ) then 
    -- print("Ignoring gc for " .. vec:uqid()) 
    return true
  end
  vec._is_dead = true
  -- print("Deleting ", vec:uqid())
  cHMap.delete(vec._base_vec)
  return true
end

-- DANGEROUS FUNCTION. Use with great care. This is because you 
-- want Lua to do garbage collection with its reference counting.
function lHMap:delete()
  if ( self._is_dead ) then
    print("HMap already dead.")
    return false
  end 
  local vname = ifxthenyelsez(self:name(), "anonymous:" .. self:uqid())
  -- print("DELETE CALLED on " .. vname)
  return true
end
--==================================================
function lHMap:self()
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  return self._base_vec
end
--=========================================================
-- Following fetch meta data about lHMap
-- These meta data items are not set directly.
-- o size()
-- o num_elements()
function lHMap:size() 
if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  return true  -- TODO 
end
--=========================================================
function lHMap:num_elements() 
if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  return true  -- TODO 
end
--=========================================================
return lHMap
