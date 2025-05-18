-- All attributes of vector start with _ to distinguish it from methods
-- So, we have lVector.width but we have self._base_vec 
-- All meta data, by convention, is in _meta.* e.g.,
-- self._meta.meaning or self._meta.max
-- Most details of an lVector are stored in C with the exception of 
-- 1) self._base_vec
-- 2) self._is_dead
-- 3) self._meta
-- 4) self._siblings
-- 4) self._generator
-- When resurrecting an lVector using Q.restore(), we don't care
-- about 
-- _is_dead  --- because all restored vectors are not dead
-- _siblings() --- because all restored vectors are fully eval'd
-- _generator() --- because all restored vectors are fully eval'd
-- _chunk_num() --- because all restored vectors are fully eval'd
-- and chunk_num only matters for lVectors that are not fully eval'd

local ffi     = require 'ffi'
local cVector = require 'libvctr'
local cutils  = require 'libcutils'
local Scalar  = require 'libsclr'
local register_type = require 'RSUTILS/lua/register_type'
local qcfg = require'Q/UTILS/lua/qcfg'
local ifxthenyelsez = require'Q/UTILS/lua/ifxthenyelsez'
--====================================
local lVector = {}
lVector.__index = lVector

-- Following hack of __gc is needed because of inability to set
-- __gc on anything other than userdata in 5.1.* 
-- This is why we need cVector.c and cannot directly ffi to the 
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
setmetatable(lVector, mt)

register_type(lVector, "lVector")

local function make_null_vec()
  return cVector.null()
end

function lVector:check()
  assert(cVector.chk(self._base_vec))
  local nn_status = true
  -- nn vector cannot have a generator 
  if ( cVector.is_nn_vec(self._base_vec) ) then 
    assert(self._generator == nil)
  end
  if ( cVector.has_nn_vec(self._base_vec) ) then 
    local nn_vec = assert(cVector.get_null_vec(self._base_vec))
    assert(cVector.min_chnk_idx(self._base_vec) == 
      cVector.min_chnk_idx(nn_vec))
    assert(cVector.max_chnk_idx(self._base_vec) == 
      cVector.max_chnk_idx(nn_vec))

    --[==[ TODO COnvert to cVector.foo from foo:()
    assert(cVector.(nn_vec:qtype() == "B1" ) or ( nn_vector:qtype() == "BL" ))
    assert(cVector.chk(nn_vector._base_vec))
    -- check congruence between base vector and nn vector
    assert(nn_vector:num_elements()  == self:num_elements())
    assert(nn_vector:is_eov()        == self:is_eov())
    assert(nn_vector:is_persist()    == self:is_persist())
    assert(nn_vector:num_readers()   == self:num_readers())
    assert(nn_vector:num_writers()   == self:num_writers())

    local b1, n1 = nn_vector:get_killable()
    local b2, n2 = self:get_killable()
    assert(b1 == b2)
    assert(n1 == n2)

    local b1, n1 = nn_vector:get_early_freeable()
    local b2, n2 = self:get_early_freeable()
    assert(b1 == b2)
    assert(n1 == n2)
    --]==]
  end 
  -- check congruence between base vector and siblings
  if ( self._siblings ) then 
    assert(type(self._siblings) == "table")
    for _, v in ipairs(self._siblings) do
      assert(v:num_elements() == self:num_elements())
      assert(v:is_eov()       == self:is_eov())
    end
  end
  --================================================
  return true
end


function lVector:chnk_incr_num_readers(chnk_idx)
  local num_readers = cVector.chnk_incr_num_readers(self._base_vec, chnk_idx)
  return num_readers
end

function lVector:num_readers(chnk_idx)
  local num_readers
  if ( not chnk_idx ) then 
    num_readers = cVector.vctr_num_readers(self._base_vec)
  else
    assert(type(chnk_idx) == "number")
    num_readers = cVector.chnk_num_readers(self._base_vec, chnk_idx)
  end
  return num_readers
end

function lVector:num_writers(chnk_idx)
  local num_writers
  if ( not chnk_idx ) then 
    num_writers = cVector.vctr_num_writers(self._base_vec)
  else
    assert(type(chnk_idx) == "number")
    num_writers = cVector.chnk_num_writers(self._base_vec, chnk_idx)
  end
  return num_writers
end

function lVector:num_chunks()
  local num_chunks = cVector.num_chunks(self._base_vec)
  assert(type(num_chunks) == "number")
  assert(num_chunks >= 0)
  return num_chunks
end

-- START: Following about name 
function lVector:name()
  local name = cVector.name(self._base_vec)
  return name
end

function lVector:set_name(name, nn_name)
  if ( name == nil ) then name = "" end 
  assert(type(name) == "string")
  if ( nn_name == nil ) then 
    if ( name == "" ) then 
      nn_name = ""
    else
      nn_name = "nn_" .. name
    end 
  end
  assert(type(nn_name) == "string")
  assert(cVector.set_name(self._base_vec, name))
  if ( cVector.has_nn_vec(self._base_vec) ) then 
    local nn_vec = cVector.get_nn_vec(self._base_vec)
    assert(cVector.set_name(nn_vec, nn_name))
  end
  return self
end
-- STOP : Following about name 

-- START : Following about is_error 
function lVector:is_error()
  local x, y = cVector.is_error(self._base_vec)
  if ( type(x) == "boolean" ) then return x else return nil end 
end

function lVector:set_error()
  local status = cVector.set_error(self._base_vec)
  return self
end
-- STOP : Above about is_error 

function lVector:drop(level)
  assert(type(level) == "number")
  assert(cVector.drop_l1_l2(self._base_vec, level))
  if ( self:has_nn_vec() ) then 
    local nn_vec = cVector.get_nn_vec(self._base_vec)
    assert(cVector.drop_l1_l2(nn_vec, level))
  end
  return self
end
-- START: Following about persist
function lVector:persist()
  local status = cVector.persist(self._base_vec)
  return self
end
function lVector:is_persist()
  local b_is_persist = cVector.is_persist(self._base_vec)
  assert(type(b_is_persist) == "boolean")
  return b_is_persist
end
-- STOP: Above about persist

function lVector:is_lma()
  local b_is_lma = cVector.is_lma(self._base_vec)
  assert(type(b_is_lma) == "boolean")
  return b_is_lma
end

function lVector:nop()
  cVector.nop(self._base_vec)
  return self
end

local function chnk_clone(v) -- for case when no lma
  -- TODO Need to support lazy evaluation of ouptut vector 
  -- Currently, we are generating entire vector here 
  assert(type(v) == "lVector")
  local vargs = {}
  vargs.qtype            = v:qtype() 
  vargs.width            = v:width() 
  vargs.max_num_in_chunk = v:max_num_in_chunk() 
  vargs.has_nulls        = v:has_nn_vec() 

  vargs.memo_len = v:get_memo()
  assert(vargs.memo_len == -1)

  local b, n = v:get_killable(); assert(b == false); assert(n == 0)
  vargs.num_lives_kill = 0

  local b, n = v:get_early_freeable(); assert(b == false); assert(n == 0)
  vargs.num_lives_free = 0

  local w = lVector(vargs)
  local chunk_num = 0
  while true do 
    local nv, v_cmem, nn_v_cmem = v:get_chunk(chunk_num)
    w:put_chunk(v_cmem, nv, nn_v_cmem)
    v:unget_chunk(chunk_num)
    if ( nv < vargs.max_num_in_chunk ) then break end 
    chunk_num = chunk_num + 1
  end
  return w
end
function lVector:clone()
  if ( not self:is_lma() ) then
    return chnk_clone(self)
  end
  assert(self:is_eov())
  local vargs = {}
  local file_name, _ = self:file_info()
  -- make a unique name 
  local t = cutils.rdtsc()
  t = t - (math.floor(t/100000000)*100000000)
  vargs.file_name = file_name .. tostring(t)
  assert(cutils.copyfile(file_name, vargs.file_name))
  --=================
  vargs.name = "clone_"
  if ( self:name() ) then 
    vargs.name = vargs.name .. self:name() 
  else 
    vargs.name = vargs.name .. self:uqid()
  end 
  vargs.qtype = self:qtype()
  vargs.max_num_in_chunk = self:max_num_in_chunk()
  vargs.num_elements = self:num_elements()
  -- following because is_eov == trye
  vargs.is_memo = false; vargs.memo_len = 0
  vargs.is_killable = false; vargs.num_kill_ignore = 0
  vargs.is_early_freeable = false; vargs.num_free_ignore = 0
  -- for k, v in pairs(vargs) do print(k, v) end 
  local z = lVector(vargs)

  -- clone the nn vector if there is one 
  if ( self:has_nn_vec() ) then 
    error("NEEDS WORK TODO P1")
    local nn_vector = assert(self._nn_vec)
    local nn_z = lVector.clone(nn_vector) -- TODO P1 Check if this works
    z:set_nulls(nn_z)
  end
  return z
end

--=================================================
function lVector.new(args)
  local vector = setmetatable({}, lVector)
  vector._meta = {} -- for meta data stored in vector
  vector._is_dead = false -- will be set to true upon deletion
  assert(type(args) == "table")
  -- TODO P1 experimental Following is to see if we can
  -- avoid gc kicking in earlier than desirable
  if ( args.gc_saver ) then vector._gc_saver = gc_saver end
  --=================================================
  if ( args.uqid )  then 
    -- print("Rehydrating " .. args.uqid)
    assert(type(args.uqid) == "number")
    assert(args.uqid > 0)
    -- START: I believe (99%) that the following is correct
    -- The reason is that tbsp = 0 is the default tablespace
    if ( not args.tbsp ) then  args.tbsp = 0 end 
    -- STOP --------------
    assert(type(args.uqid) == "number")
    assert(args.uqid >= 0)
    vector._base_vec = cVector.rehydrate(args)
    assert(vector._base_vec)
    if ( qcfg.debug ) then 
      assert(cVector.chk(vector._base_vec, false, false))
    end
    -- get following from cVector
    -- max_num_in_chunk
    -- memo_len
    -- TODO P1 Why do we store this on Lua side? Why not on C side?
    -- TODO In fact why store *anything* on Lua side that can be in C?
    vector._max_num_in_chunk = cVector.max_num_in_chunk(vector._base_vec)
    vector._memo_len        = cVector.get_memo(vector._base_vec)
    vector._qtype           = cVector.qtype(vector._base_vec)
    -- If vector has nulls, do following 
    if ( args.nn_uqid ) then 
      local nn_uqid = args.nn_uqid
      assert(type(nn_uqid) == "number")
      assert(nn_uqid > 0)
      local nn_vec = assert(cVector.rehydrate({ uqid = nn_uqid}))
      assert(cVector.set_nn_vec(vector._base_vec, nn_vec))
    end 
    vector:persist(false) -- IMPORTANT
    return vector 
  end
  --=================================================

  if ( args.gen ) then vector._generator = args.gen end 
  --=================================================
  assert(type(args.qtype) == "string")
  --=================================================
  if ( args.max_num_in_chunk ) then 
    assert(type(args.max_num_in_chunk) == "number")
    assert(args.max_num_in_chunk > 0)
    assert( math.floor(args.max_num_in_chunk / 64 ) == 
            math.ceil(args.max_num_in_chunk / 64 ) )
  else
    args.max_num_in_chunk = qcfg.max_num_in_chunk
  end
  --=================================================
  if ( args.is_memo ~= nil ) then 
    assert(type(args.is_memo) == "boolean")
  end
  if ( args.memo_len ~= nil ) then 
    assert(type(args.memo_len) == "number")
  end
  if ( type(args.memo_len) == "number" ) then 
    if ( args.memo_len <= 0 ) then 
      if ( args.is_memo == nil ) then 
        args.is_memo = false
      else
        assert( args.is_memo == false)
      end
    else
      if ( args.is_memo == nil ) then 
        args.is_memo = true
      else
        assert( args.is_memo == true)
      end
    end
  else
    args.is_memo  = qcfg.is_memo
    args.memo_len = qcfg.memo_len
  end
  --=================================================
  if ( type(args.is_killable) == "boolean" ) then 
    assert(type(args.num_kill_ignore) == "number")
    assert(args.num_kill_ignore >= 0)
  else
    args.is_killable  = qcfg.is_killable
    args.num_kill_ignore = qcfg.num_kill_ignore
  end
  --=================================================
  if ( type(args.is_early_freeable) == "boolean" ) then 
    assert(type(args.num_free_ignore) == "number")
    assert(args.num_free_ignore >= 0)
  else
    args.is_early_freeable  = qcfg.is_early_freeable
    args.num_free_ignore = qcfg.num_free_ignore
  end
  --=================================================
  vector._base_vec = assert(cVector.add(args))
  local nn_vector
  if ( args.has_nulls ) then 
    -- assemble args for nn Vector 
    local nn_args = {}
    local nn_qtype = "BL"
    if ( args.nn_qtype ) then 
      assert(type(args.nn_qtype) == "string")
      nn_qtype = args.nn_qtype
    end
    nn_args.qtype = nn_qtype
    assert((nn_qtype == "B1") or (nn_qtype == "BL"))
    if ( args.name ) then 
      nn_args.name = "nn_" .. args.name 
    end
    -- following must be in sync with primary vector 
    nn_args.max_num_in_chunk  = args.max_num_in_chunk 
    nn_args.is_memo   = args.is_memo 
    nn_args.memo_len  = args.memo_len 

    nn_args.is_killable  = args.is_killable 
    nn_args.num_kill_ignore  = args.num_kill_ignore 

    nn_args.is_early_freeable  = args.is_early_freeable 
    nn_args.num_free_ignore  = args.num_free_ignore 
    -- above must be in sync with primary vector 
    ----------------------------------- 
    nn_vector = setmetatable({}, lVector)
    -- for k, v in pairs(nn_args) do print(k, v) end 
    nn_vector._base_vec = assert(cVector.add(nn_args))
    assert(cVector.set_nn_vec(vector._base_vec, nn_vector._base_vec))
    local uqid = cVector.uqid(vector._base_vec)
    local nn_uqid = cVector.uqid(nn_vector._base_vec)
    if ( args.name ) then 
      -- print("For " .. args.name .. ", " .. nn_uqid .. " assigned as nn of " .. uqid)
    else
      -- print(nn_uqid .. " assigned as nn of " .. uqid)
    end
  end 
  --=================================================
  return vector
end
--=======================================================
function lVector:put1(sclr, nn_sclr)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  -- cannot put into complete vector 
  assert(self:is_eov() == false) 
  -- cannot put into nn vector 
  assert(not cVector.is_nn_vec(self._base_vec))
  assert(type(sclr) == "Scalar")
  --========================
  local nn_vec
  local has_nn_vec = cVector.has_nn_vec(self._base_vec)
  -- nn_sclr can be provided only if vector has nulls
  if ( type(nn_sclr) ~= "nil" ) then 
    assert(has_nn_vec == true)
  end
  -- if vector has nulls, must be of type BL -- Limitation
  -- if vector has nulls, nn_sclr must be provided
  if ( has_nn_vec ) then 
    nn_vec = assert(cVector.get_nn_vec(self._base_vec))
    assert(nn_vec:qtype() == "BL") -- current limitation
    assert(type(nn_sclr) == "Scalar") 
    assert(nn_sclr:qtype() == "BL")
  end
  --========================
  assert(cVector.put1(self._base_vec, sclr))
  if ( has_nn_vec ) then 
    assert(cVector.put1(nn_vec, nn_sclr))
  end
  return self
end
--=======================================================
function lVector:putn(col, n, nn_col)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  -- cannot put into complete vector 
  assert(self:is_eov() == false) 
  -- cannot put into nn vector 
  assert(not cVector.is_nn_vec(self._base_vec))
  --===========
  assert(type(col) == "CMEM")
  if ( type(n) == "nil" ) then n = 1 end
  assert(type(n) == "number"); assert(n > 0)
  --========================
  local nn_vec
  local has_nn_vec = cVector.has_nn_vec(self._base_vec)
  -- nn_col can be provided only of vector has nulls
  if ( type(nn_col) ~= "nil" ) then 
    assert(has_nn_vec == true)
  end
  -- if vector has nulls, nn_col must be provided 
  -- if vector has nulls, nn vector must be of type BL
  if ( has_nn_vec ) then 
    nn_vec = assert(cVector.get_nn_vec(self._base_vec))
    assert(nn_vec:qtype() == "BL") -- current limitation
  end 
  -- if nn_col, then it must be CMEM 
  if ( nn_col ) then assert(type(nn_col) == "CMEM") end
  --========================
  assert(cVector.putn(self._base_vec, col, n))
  if ( has_nn_vec ) then 
    assert(cVector.putn(nn_vec, nn_col, n))
  end
  return self
end
--=======================================================
function lVector:put_chunk(chnk, n, nn_chnk)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  -- cannot put into complete vector 
  assert(self:is_eov() == false) 
  -- cannot put into nn vector 
  assert(not cVector.is_nn_vec(self._base_vec))
  --============
  assert(type(chnk) == "CMEM")
  assert(type(n) == "number")
  assert(n > 0) -- cannot put empty chunk 
  if ( nn_chnk ) then assert(type(nn_chnk) == "CMEM") end 
  --============
  local nn_vec
  local has_nn_vec = cVector.has_nn_vec(self._base_vec)
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
    nn_vec = assert(cVector.get_nn_vec(self._base_vec))
    assert(nn_vec:qtype() == "BL") -- current limitation
  end 
  --=== Checks complete, ready to do work
  assert(cVector.put_chunk(self._base_vec, chnk, n))
  if ( has_nn_vec ) then  
    assert(cVector.put_chunk(nn_vec, nn_chnk, n))
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

function lVector:get1(elem_idx)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  local nn_sclr
  assert(type(elem_idx) == "number")
  if (elem_idx < 0) then return nil end
  local sclr = cVector.get1(self._base_vec, elem_idx)
  if ( sclr ) then assert(type(sclr) == "Scalar") end
  if ( cVector.has_nn_vec(self._base_vec) and sclr ) then 
    local nn_vec = cVector.get_nn_vec(self._base_vec)
    nn_sclr = cVector.get1(nn_vec, elem_idx)
    assert(type(nn_sclr) == "Scalar") 
    assert(nn_sclr:qtype() == "BL") 
  end
  return sclr, nn_sclr
end

function lVector:unget_chunk(chnk_idx)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end

  assert(cVector.unget_chunk(self._base_vec, chnk_idx))
  if ( cVector.has_nn_vec(self._base_vec) ) then 
    local nn_vec = cVector.get_nn_vec(self._base_vec)
    assert(cVector.unget_chunk(nn_vec, chnk_idx))
  end
end

function lVector:get_chunk(chnk_idx)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  local vname = ifxthenyelsez(self:name(), "anonymous_" .. self:uqid())
  -- print("getting chunk " .. chnk_idx .. " for " .. vname)

  assert(type(chnk_idx) == "number")
  assert(chnk_idx >= 0)

  local max_chnk_idx = self:max_chnk_idx()
  local num_elements = self:num_elements()
  local to_generate 
  if ( self:is_eov() ) then
    to_generate = false
  else
    if ( ( num_elements == 0 ) or ( chnk_idx == (max_chnk_idx+1) ) ) then 
      to_generate = true
      -- cannot have generator on on nn vec, only on primary vec
      assert(not cVector.is_nn_vec(self._base_vec))
    else
      to_generate = false
    end
    assert(chnk_idx <= (max_chnk_idx+1), "Asking for chunk too far out")
  end
  --[[ TODO Should we allow get_chunk on nn_vec?
  -- Current assumption is NO
  if ( to_generate and ( self._generator == nil ) and self._parent ) then 
    -- print(" invoke the parent generator  for " .. self:name())
    if ( not self._parent._generator ) then 
      print("ERROR: Expected parent generator for " .. self:name())
    end
    self._parent:get_chunk(chnk_idx)
    self._parent:unget_chunk(chnk_idx)
    to_generate = false
    -- TODO P1 Put more checks in here
  end
  --]]
  if ( to_generate ) then -- IF TO GENERATE
    if ( not self._generator ) then 
      print("ERROR: Expected generator for " .. self:name())
      return 0, nil 
    end 
    local num_elements, buf, nn_buf = self._generator(chnk_idx)
    assert(type(num_elements) == "number")
    -- IMPORTANT: See how error in Vector creation is indicated
    if ( ( num_elements == 0 ) and 
         ( type(buf) == "boolean" ) and ( buf == false ) ) then 
      self:set_error()
    end
    --==============================
    if ( num_elements > 0 ) then  
      assert(type(buf) == "CMEM")
      self:put_chunk(buf, num_elements, nn_buf)
    end
    --==============================, NUmber of elements
    if ( num_elements < self:max_num_in_chunk() ) then 
      -- print("EOV for " .. self:name() .. ". num_elements = ", num_elements)
      -- nothing more to generate
      self:eov()  -- vector is at an end 
    end
    --==============================
    -- check for early termination
    if ( num_elements == 0 ) then 
      -- following delete is an additional precuation. Ideally
      -- generator would have deleted it in this case
      if ( buf ) then assert(type(buf) == "CMEM"); buf:delete() end 
      if ( nn_buf ) then assert(type(nn_buf) == "CMEM"); nn_buf:delete() end 
      return 0 
    end 
    --===========================
    if ( self._siblings ) then
      -- print("Processing siblings of " .. self:name())
      assert(type(self._siblings) == "table")
      assert(#self._siblings > 0)
      for _, v in ipairs(self._siblings) do
        assert(type(v) == "lVector") assert(type(v) == "lVector")
--[[
        print("Vector " .. self:name(), " requesting chunk " .. chnk_idx .. 
          " for sibling", v:name())
--]]
        local x, y, z = v:get_chunk(chnk_idx)
        assert(x == num_elements)
        if ( x < self:max_num_in_chunk() ) then 
          -- print("Sibling EOV for " .. v:name())
          v:eov()  -- vector is at an end 
        end
        -- following because we aren't really consuming the chunk
        -- we are just getting it 
        v:unget_chunk(chnk_idx)
        if ( qcfg.debug ) then 
          -- Checks if chunks that should have been deleted because of
          -- memo_len, have in fact been deleted 
          if ( ( v:get_memo() >= 0 ) and ( v:num_elements() > 0 ) ) then
            local chunk_to_release = chunk_idx - self._memo_len
            if ( chunk_to_release >= 0 ) then 
              -- print("Sibling: Deleting chunk " .. chunk_to_release)
              local is_found = 
                cVector.chunk_delete(self._base_vec, chunk_to_release)
              assert(is_found == false)
            end
          end
       end
      end
    end
    -- TODO P2 Why is incr_num_readers is being done in Lua and not in C???
    assert(self:chnk_incr_num_readers(chnk_idx))
    if ( cVector.has_nn_vec(self._base_vec) ) then 
      local nn_vec = cVector.get_nn_vec(self._base_vec)
      assert(cVector.chnk_incr_num_readers(nn_vec, chnk_idx))
    end
    -- print("Returning " .. num_elements .. " for " .. self:name())
    -- TODO print("XXX", chnk_idx, self:num_readers(chnk_idx), self:name())
    -- TODO assert(self:num_readers(chnk_idx) == 1)
    return num_elements, buf, nn_buf
  else -- ELSE OF IF TO GENERATE
    -- print(" Archival chunk for " .. self:name(), chnk_idx)
    if ( qcfg.debug ) then self:check(false) end 
    local nn_x, nn_n
    local x, n = cVector.get_chunk(self._base_vec, chnk_idx)
    if ( x == nil ) then return 0, nil, nil end 
    if ( self:has_nn_vec() ) then 
      local nn_vec = cVector.get_nn_vec(self._base_vec)
      if ( n == 29316 ) then
        self:nop()
        nn_vector:nop()
      end
      -- print("A getting for ", self:name(), n)
      -- print("B getting for ", nn_vector:name())
      nn_x, nn_n = cVector.get_chunk(nn_vec,chnk_idx)
      -- print("gotten  for ", nn_vector:name())
      assert(type(nn_n) == "number")
      assert(nn_n == n)
      assert(type(nn_x) == "CMEM")
    end
    assert(type(n) == "number")
    assert(type(x) == "CMEM")
    return n, x, nn_x
  end
end
-- evaluates the vector using a provided generator function
-- when done, is_eov() will be true for this vector
-- if is_eov() at time of call, nothing is done 
function lVector:eval()
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  if ( self:is_eov() ) then return self end 
  local max_num_in_chunk = cVector.max_num_in_chunk(self._base_vec)
  repeat
    local chunk_to_get
    local max_chnk_idx = self:max_chnk_idx()
    if ( self:num_elements() == 0 ) then 
      chunk_to_get = 0
    else
      chunk_to_get = max_chnk_idx + 1
    end
    local num_elements, buf, nn_buf = self:get_chunk(chunk_to_get)
    if ( nn_buf ) then assert(type(nn_buf) == "CMEM") end 
    if (    buf ) then assert(type(   buf) == "CMEM") end 
    assert(type(num_elements) == "number")
    -- this unget needed because get_chunk increments num readers 
    -- and the eval doesn't actually get the chunk for itself
    -- Consider zero element array case caefully
    local chunk_to_unget = chunk_to_get
    if ( num_elements == 0 ) then
      -- nothing to unget
    else
      -- print("Ungetting " .. chunk_to_unget .. " for " .. self:name())
      assert(cVector.unget_chunk(self._base_vec, chunk_to_unget))
      if ( self:has_nn_vec() ) then 
        local nn_vec = cVector.get_nn_vec(self._base_vec)
        assert(cVector.unget_chunk(nn_vec, chunk_to_unget))
      end
    end
  until ( num_elements ~= max_num_in_chunk ) 
  assert(self:is_eov())
  --[[ TODO THINK P1 
  -- cannot have Vector with 0 elements
  if ( self:num_elements() == 0 ) then  return nil  end
  -- 07/2019
  -- This delete() is an important change from previous implemenation.
  -- The generator that gave us the data would have allocated a CMEM
  -- Now that the Vector has been fully created, that is not needed
  -- Hence ,its okay to go ahead and delete the memory within the CMEM
  -- Note that the deletion of the CMEM itself is up to Lua
  if ( type(self._gen) == "function" ) then 
    if (    base_addr ) then    base_addr:delete() end 
    if ( nn_base_addr ) then nn_base_addr:delete() end 
    self._generator = nil -- generation all done => no generator needed
  end
  --]]
  if ( qcfg.debug ) then self:check() end
  return self
end

function lVector:pr(opfile, lb, ub, format)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  local nn_vec
  if ( cVector.has_nn_vec(self._base_vec) ) then
    nn_vec = cVector.get_nn_vec(self._base_vec)
  else
    nn_vec = make_null_vec()
  end
  --=================================
  if ( ( opfile )  and ( #opfile > 0 ) ) then
    assert(type(opfile) == "string")
  else
    opfile = ffi.NULL
  end
  --=================================
  if ( lb ) then
    assert(type(lb) == "number")
    assert(lb >= 0)
  else
    lb = 0
  end
  --=================================
  if ( ub ) then -- upper bound exclusive
    assert(type(ub) == "number")
    if ( ub ~= 0 ) then assert(ub > lb)  end
    assert(ub <= self:num_elements())
  else
    ub = self:num_elements()
  end
  --=================================
  if ( ( format ) and (#format > 0 ) ) then
    assert(type(format) == "string")
  else
    format = ""
  end
  --=================================
  assert(cVector.pr(self._base_vec, nn_vec, opfile, lb, ub, format))
  return true
end
--========================================================
-- START: Following about meta data 
function lVector:get_meta(key)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  assert(type(key) == "string")
  if ( self._meta ) then 
    assert(type(self._meta) == "table")
    if self._meta[key] then 
      return self._meta[key] 
    else
      return nil
    end
  else
    return nil
  end
end
--========================================================
function lVector:unset_meta(key)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  assert(type(key) == "string")
  if ( not self._meta ) then return self end 
  if ( self._meta ) then 
    assert(type(self._meta) == "table")
    if ( self._meta[key] ) then 
      self._meta[key] = nil
    end
  end
  return self
end
--========================================================
function lVector:set_meta(key, value)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  assert(type(key) == "string")
  assert(value)
  if ( not self._meta ) then self._meta = {} end 
  self._meta[key] = value
  return self
end
-- STOP : Above about meta data 
--========================================================

lVector.__gc = function (vec)
  if ( vec._is_dead ) then
    -- print("Vector already dead.")
    return false
  end 
  if ( cVector.is(vec._base_vec) ) then 
    local vname = ifxthenyelsez(vec:name(), "anonymous_" .. vec:uqid())
    -- print("GC CALLED on " .. tostring(vec:uqid()) .. " -> " .. vname)
  else
    return true -- already deleted 
  end
  --=========================================
  --[[ Not needed because done on C side 
  -- TODO P1 I don't think this is enough. Causes problems
  -- when we save and restore 
  if ( vec:has_nn_vec() ) then 
    local nn_vec = cVector.get_nn_vec(self._base_vec)
    cVector.delete(nn_vec)
  end
  --]]
  if ( cVector.has_parent(vec._base_vec) ) then 
    -- print("Ignoring gc for " .. vec:uqid()) 
    return true
  end
  vec._is_dead = true
  -- print("Deleting ", vec:uqid())
  cVector.delete(vec._base_vec)
  return true
end

-- DANGEROUS FUNCTION. Use with great care. This is because you 
-- want Lua to do garbage collection with its reference counting.
-- Else, you could end up in the followint situation
-- x = lVector(....) -- create  a vector pointed to by x 
-- y = x 
-- x:delete()
-- y is left hanging to an empty vector -- dangerous situation
function lVector:delete()
  if ( self._is_dead ) then
    print("Vector already dead.")
    return false
  end 
  local vname = ifxthenyelsez(self:name(), "anonymous:" .. self:uqid())
  -- print("DELETE CALLED on " .. vname)
  -- cannot delete nn_vec, need to delete primary vec
  if ( cVector.is_nn_vec(self._base_vec) ) then 
    print("Need to kill parent, not me") 
    return false
  end
  -- delete of primary vector will trigger delete of nn vector if exists
  self._is_dead = true
  return  cVector.delete(self._base_vec)
end

-- START: Following for siblings
function lVector:siblings()
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  if ( not self._siblings ) then return nil end
  local T = {}
  if ( self._siblings ) then 
    assert(type(self._siblings) == "table")
    for k, v in ipairs(self._siblings ) do 
      assert(type(v) == "lVector")
      T[k] = v:name()
    end
  end
  return T
end

-- add_sibling is not invoked from outside 
-- we add v2 to siblings of v1 
local function add_sibling(v1, v2)
  if ( v1.is_dead ~= nil ) then assert(v1._is_dead == false) end
  if ( v2.is_dead ~= nil ) then assert(v2._is_dead == false) end
  -- can add a sibling only when both vectors are empty
  assert(type(v1) == "lVector")
  assert(type(v2) == "lVector")
  assert(v1:num_elements() == 0)
  assert(v2:num_elements() == 0)
  --=======================================
  if ( not v1._siblings ) then 
    v1._siblings = {}
  end
  assert(type(v1._siblings) == "table")
  -- Cannot add v2 to siblings of v1 if it is already a sibling of v1
  for k,  v in ipairs(v1._siblings) do 
    assert(v ~= v2)
  end 
  v1._siblings[#v1._siblings+1] = v2
end

function lVector.conjoin(T)
  assert(type(T) == "table")
  assert(#T > 1)
  for k1, v1 in ipairs(T) do
    assert(type(v1) == "lVector")
    -- can conjoin only if vector is empty
    assert(v1:num_elements() == 0 )
    for k2, v2 in ipairs(T) do
      if ( k1 ~= k2 ) then
        assert(v1:max_num_in_chunk() == v2:max_num_in_chunk())
        -- print("Adding " .. v2:name() .. " as sibling of " .. v1:name())
        add_sibling(v1, v2)
      end
    end
  end
end
-- STOP: Above for siblings
--==================================================
-- self is destination, x is source 
function lVector:append(x)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  assert(type(x) == "lVector")
  if ( x.is_dead ~= nil ) then assert(x._is_dead == false) end
  --=================
  assert(x:is_eov())
  if ( not x:is_lma() ) then x:chunks_to_lma() end
  assert(x:is_lma())
  --=================
  assert(self:is_eov())
  if ( not self:is_lma() ) then self:chunks_to_lma() end
  assert(self:is_lma())
  --=================
  -- either both have nn vecs or neither does
  if ( self:has_nn_vec() ) then assert(x:has_nn_vec()) end 
  if ( not self:has_nn_vec() ) then assert(not x:has_nn_vec()) end 
  --=================

  assert(cVector.append(self._base_vec, x._base_vec))
  if ( self:has_nn_vec() ) then 
    local self_nn_vec = assert(cVector.get_nn_vec(self._base_vec))
    local x_nn_vec    = assert(cVector.get_nn_vec(x._base_vec))
    assert(cVector.append(self_nn_vec, x_nn_vec))
  end
  return  true -- TODO P0 MAJOR HACK 
  -- WHY NOT THIS? return self
end
-- START: Following for early_free
-- REGARDING early free. This was motivated by the following case
-- Say you do z := x where y.
-- since we produce z in full chunks, we might consume n >1 chunks of x, y
-- before we produce a full chunk of z. 
-- So, we cannot x:set_memo(n) since we don't know what n would be 
-- When early_free() is called on a vector which is earlyii_freeable()
-- we delete all but the last chunk
--==================================================
function lVector:early_free(chnk_idx)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  assert(type(chnk_idx) == "number")
  assert(not self:is_nn_vec()) -- early free works only on primary 
  assert(cVector.early_free(self._base_vec, chnk_idx))
  -- call early_free on nn vector if one exists
  if ( cVector.has_nn_vec(self._base_vec) ) then 
    local nn_vec = assert(cVector.get_null_vec(self._base_vec))
    assert(cVector.early_free(nn_vec, chnk_idx))
  end
  return self
end
--==================================================
function lVector:get_early_freeable() 
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  assert(not self:is_nn_vec()) -- early free works only on primary 

  local b_is_early_free, num_lives_free = 
    cVector.get_early_freeable(self._base_vec)
  assert(type(b_is_early_free) == "boolean")
  assert(type(num_lives_free) == "number")
  return b_is_early_free, num_lives_free
end
--==================================================
function lVector:set_early_freeable(num_lives) -- equivalent of killable()
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  if ( num_lives == nil ) then num_lives = 0 end -- set default 
  assert(type(num_lives) == "number")
  assert(not self:is_nn_vec()) -- early free works only on primary 

  assert(cVector.set_early_freeable(self._base_vec, num_lives))
  return self
end
-- STOP: Above for early_free
--==================================================
function lVector:self()
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  return self._base_vec
end
--==================================================
function lVector:chunks_to_lma()
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  if ( self:is_lma() ) then --[[ nothing to do --]]  return self end 
  assert(cVector.chnks_to_lma(self._base_vec))
  if ( self:has_nn_vec() ) then 
    local nn_vec = cVector.get_nn_vec(self._base_vec)
    assert(cVector.chnks_to_lma(nn_vec))
  end
  return self
end
--==================================================
function lVector:lma_to_chunks()
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  -- TODO VERIFY THAT THIS IS IDEMPOTENT. 
  assert(cVector.lma_to_chnks(self._base_vec))
  if ( self:has_nn_vec() ) then 
    local nn_vec = cVector.get_nn_vec(self._base_vec)
    assert(cVector.lma_to_chnks(nn_vec))
  end
  return self
end
--==================================================
function lVector:get_lma_read()
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  local x, nn_x
  local x = assert(cVector.get_lma_read(self._base_vec))
  if ( self:has_nn_vec() ) then 
    local nn_vec = cVector.get_nn_vec(self._base_vec)
    nn_x = assert(cVector.get_lma_read(nn_vec))
  end
  return x, nn_x, self:num_elements()
end
--==================================================
function lVector:get_lma_write()
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  local x, nn_x
  local x = assert(cVector.get_lma_write(self._base_vec))
  if ( self:has_nn_vec() ) then 
    local nn_vec = cVector.get_nn_vec(self._base_vec)
    nn_x = assert(cVector.get_lma_write(nn_vec))
  end
  -- FOLLOWING IS SUPER IMPORTANT 
  -- If there are chunks, we need to delete them 
  -- This is because the request for write access => changes to lma file
  -- Then, the chunks are no longer consistent.
  self:drop_mem(1)
  self:drop_mem(2)
  if ( self:has_nn_vec() ) then 
    local nn_vec = cVector.get_nn_vec(self._base_vec)
    assert(cVector.drop_mem(nn_vec, 1))
    assert(cVector.drop_mem(nn_vec, 2))
  end 
  return x, nn_x, self:num_elements()
end
--==================================================
function lVector:unget_lma_read()
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  assert(cVector.unget_lma_read(self._base_vec))
  if ( self:has_nn_vec() ) then 
    local nn_vec = cVector.get_nn_vec(self._base_vec)
    assert(cVector.unget_lma_read(nn_vec))
  end
  return self
end
--==================================================
function lVector:unget_lma_write()
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  assert(cVector.unget_lma_write(self._base_vec))
  if ( self:has_nn_vec() ) then 
    local nn_vec = cVector.get_nn_vec(self._base_vec)
    assert(cVector.unget_lma_write(nn_vec))
  end
  return self
end
--==================================================
-- START: Following about killable
-- (a) get_killable()
-- (b) kill()
-- (c) set_killable
-- use this function to set kill-ability of vector 
function lVector:set_killable(val)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  assert(type(val) == "number")
  assert(val >= 0)
  assert(not self:is_nn_vec()) -- killable not property of nn vec 

  assert(cVector.set_num_kill_ignore(self._base_vec, val))
  return self
end
--==================================================
function lVector:get_killable()
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  assert(not self:is_nn_vec()) -- killable not property of nn vec 

  local b_is_killable, num_kill_ignore = 
    cVector.get_num_kill_ignore(self._base_vec)
  assert(type(b_is_killable) == "boolean")
  assert(type(num_kill_ignore) == "number")
  return b_is_killable, num_kill_ignore
end
--==================================================
-- will delete the vector *ONLY* if marked as is_killable; else, NOP
function lVector:kill()
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  assert(not self:is_nn_vec()) -- can kill primary, not associated nn
  local nn_success
  -- print("Lua received kill for " .. self:name())
  local success = cVector.kill(self._base_vec)
  if ( self:has_nn_vec() ) then 
    -- print("Lua received kill for nn of " .. self:name())
    local nn_vec = cVector.get_nn_vec(self._base_vec)
    nn_success = cVector.kill(nn_vec)
  end
  return success, nn_success
end
-- STOP: Above about killable
--==================================================
function lVector:drop_mem(level, chnk_idx)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  assert(type(level) == "number")
  if ( not chnk_idx ) then chnk_idx = -1 end
  assert(type(chnk_idx) == "number")
  local rslt = cVector.drop_mem(self._base_vec, level, chnk_idx)
  local nn_rslt
  if ( self:has_nn_vec() ) then 
    local nn_vec = cVector.get_nn_vec(self._base_vec)
    local nn_rslt = cVector.drop_mem(nn_vec, level, chnk_idx)
  end
  return rslt, nn_rslt
end
--==================================================
function lVector:make_mem(level, chnk_idx)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  assert(type(level) == "number")
  if ( not chnk_idx ) then chnk_idx = -1 end
  assert(type(chnk_idx) == "number")
  local rslt = cVector.make_mem(self._base_vec, level, chnk_idx)
  local nn_rslt
  if ( self:has_nn_vec() ) then 
    local nn_vec = cVector.get_nn_vec(self._base_vec)
    local nn_rslt = cVector.make_mem(nn_vec, level, chnk_idx)
  end
  return rslt, nn_rslt
end
--==================================================
function lVector:cast(qtype) -- DANGEROUS, USE WITH CAUTION
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  assert(not self:is_nn_vec()) -- can only cast primary 
  assert(type(qtype) == "string")
  assert(cVector.cast(self._base_vec, qtype))
  return self
end
--==================================================
--==================================================
-- START: about memo_len
-- is_memo()
-- get_memo_len()
-- set_memo()
function lVector:is_memo()
  local is_memo = cVector.is_memo(self._base_vec)
  assert(type(is_memo) == "boolean")
  return is_memo
end
function lVector:get_memo()
  local memo_len, is_memo = cVector.get_memo(self._base_vec)
  assert(type(memo_len) == "number")
  assert(type(is_memo) == "boolean")
  return memo_len, is_memo
end
function lVector:set_memo(memo_len)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  if ( memo_len == nil ) then 
    memo_len = qcfg.memo_len
  end
  assert(type(memo_len == "number"))
  assert(cVector.set_memo(self._base_vec, memo_len))
  if ( cVector.has_nn_vec(self._base_vec )) then 
    local nn_vec = cVector.get_nn_vec(self._base_vec )
    assert(cVector.set_memo(nn_vec, memo_len))
  end
  return self
end
-- STOP : about memo_len
--=================================================
-- START : about eov()
function lVector:eov()
  -- cannot call eov on nn_vec, only on primary vec
  assert(not  cVector.is_nn_vec(self._base_vec )) 
  assert(cVector.eov(self._base_vec))
  self._generator = nil -- IMPORTANT, we no longer have a generator 

  if ( cVector.has_nn_vec(self._base_vec )) then 
    local nn_vec = cVector.get_nn_vec(self._base_vec )
    assert(cVector.eov(nn_vec))
  end
  return self
end
function lVector:is_eov()
  local b_is_eov = cVector.is_eov(self._base_vec)
  assert(type(b_is_eov) == "boolean")
  return b_is_eov
end
-- STOP : about eov()

--====================================================================
-- These functions deal with nn vec
-- brk_nn_vec
-- get_nn_vec
-- has_nn_vec
-- is_nn_vec
-- set_nn_vec
-- del_nn_vec
function lVector:brk_nn_vec()
  assert(cVector.brk_nn_vec(self._base_vec))
  return self
end
function lVector:del_nn_vec()
  assert(cVector.del_nn_vec(self._base_vec))
  return self
end
function lVector:get_nn_vec()
  -- print("Getting nn_vec for ", self:name())
  local nn_vector = setmetatable({}, lVector)
  nn_vector._base_vec = cVector.get_nn_vec(self._base_vec)
  return nn_vector
end
function lVector:has_nulls() -- for backward compatibility, deprecate
  return cVector.has_nn_vec(self._base_vec)
end
function lVector:has_nn_vec()
  return cVector.has_nn_vec(self._base_vec)
end
function lVector:is_nn_vec()
  return cVector.is_nn_vec(self._base_vec)
end
function lVector:set_nn_vec(nn_vec)
  if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  -- nn_vec must be a Vector of type B1 or BL
  assert(type(nn_vec) == "lVector")
  assert((nn_vec:qtype() == "BL") or (nn_vec:qtype() == "B1"),
    "nn_vec qtype = " .. nn_vec:qtype())
  -- must not have an nn_vec currently
  assert(not cVector.has_nn_vec(self._base_vec))
  -- cannot set nn_vec to an nn_vec
  assert(not cVector.is_nn_vec(self._base_vec))
  -- Limitation of current implementation
  -- input nn_vec cannot be the nn vec for another vector
  assert(not cVector.is_nn_vec(nn_vec._base_vec))
  -- cannot be your own nn_vec 
  assert(self:uqid() ~= nn_vec:uqid())
  --===============
  assert(type(nn_vec) == "lVector")
  assert(nn_vec:has_nn_vec() == false) -- nn cannot have nulls
  -- Limitation of current implementation
  assert(nn_vec:is_eov()) 
  assert(self:is_eov()) 
  --================
  assert(nn_vec:num_elements() == self:num_elements()) -- sizes must match
  assert(nn_vec:qtype() == "BL") -- Limitation, B1 not supported

  -- after all checks have passed, we can do the real work 
  assert(cVector.set_nn_vec(self._base_vec, nn_vec._base_vec))
  return self 
end

--=========================================================
-- Following fetch meta data about lVector
-- These meta data items are not set directly.
-- o file_info()
-- o max_num_in_chunk()
-- o has_gen()
-- o num_elements()
-- o width()
-- o uqid()
-- o tbsp()
-- o qtype()
-- o nn_qtype()
-- o max_chnk_idx()
-- o min_chnk_idx()
function lVector:file_info() 
if ( self.is_dead ~= nil ) then assert(self._is_dead == false) end
  local file_name, sz = cVector.file_info(self._base_vec)
  if ( file_name == ffi.NULL ) then return nil, 0 end 
  return file_name, sz
end
function lVector:max_num_in_chunk()
  local max_num_in_chunk = cVector.max_num_in_chunk(self._base_vec)
  assert(max_num_in_chunk > 0)
  return max_num_in_chunk
end

function lVector:width()
  local width = assert(cVector.width(self._base_vec))
  assert(width > 0)
  return width
end

function lVector:num_elements()
  local num_elements = cVector.num_elements(self._base_vec)
  assert(type(num_elements) == "number")
  assert(num_elements >= 0)
  return num_elements
end

function lVector:has_gen()
  if ( self._generator ) then return true  else return false end 
end
function lVector:uqid()
  local uqid = cVector.uqid(self._base_vec)
  assert(type(uqid) == "number"); assert(uqid > 0)
  return uqid
end
--=================================================
function lVector:max_chnk_idx()
  local max_chnk_idx = cVector.max_chnk_idx(self._base_vec)
  assert(type(max_chnk_idx) == "number"); assert(max_chnk_idx >= 0)
  return max_chnk_idx
end
--=================================================
function lVector:min_chnk_idx()
  local min_chnk_idx = cVector.min_chnk_idx(self._base_vec)
  assert(type(min_chnk_idx) == "number"); assert(min_chnk_idx >= 0)
  return min_chnk_idx
end
--=================================================
function lVector:tbsp()
  local tbsp = cVector.tbsp(self._base_vec)
  assert(type(tbsp) == "number"); assert(tbsp >= 0)
  return tbsp
end
--=================================================
function lVector:qtype()
  return cVector.qtype(self._base_vec)
end
--=================================================
function lVector:nn_qtype()
  if ( not cVector.has_nn_vec(self._base_vec) ) then return nil end 
  local nn_vec = assert(cVector.get_nn_vec(self._base_vec))
  local nn_qtype = assert(cVector.qtype(nn_vec))
  return  nn_qtype
end
--=========================================================
return lVector
