-- All attributes of vector start with _ to distinguish it from methods
-- So, we have lVector.width but we have self._base_vec or self._chunk_num
-- All meta data, by convention, is in _meta.* e.g.,
-- self._meta.meaning or self._meta.max
local ffi     = require 'ffi'
local cVector = require 'libvctr'
local cutils  = require 'libcutils'
local Scalar  = require 'libsclr'
local register_type = require 'Q/UTILS/lua/register_type'
local qcfg = require'Q/UTILS/lua/qcfg'
--====================================
local function ifxthenxelsey(x, y)
  if ( x ) then return x else return y end
end
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

function lVector:check()
  assert(cVector.chk(self._base_vec))
  local nn_status = true
  if ( self._nn_vec ) then 
    local nn_vector = assert(self._nn_vec)
    assert(nn_vector._chunk_num == self._chunk_num)
    assert(type(nn_vector) == "lVector")
    assert(( nn_vector:qtype() == "B1" ) or ( nn_vector:qtype() == "BL" ))
    assert(cVector.chk(nn_vector._base_vec))
    -- check congruence between base vector and nn vector
    assert(nn_vector:num_elements()  == self:num_elements())
    assert(nn_vector:is_eov()        == self:is_eov())
    assert(nn_vector:is_persist()    == self:is_persist())
    assert(nn_vector:num_readers()   == self:num_readers())
    assert(nn_vector:num_writers()   == self:num_writers())

    local b1, n1 = nn_vector:is_killable()
    local b2, n2 = self:is_killable()
    assert(b1 == b2)
    assert(n1 == n2)

    local b1, n1, m1 = nn_vector:is_early_freeable()
    local b2, n2, m2 = self:is_early_freeable()
    assert(b1 == b2)
    assert(n1 == n2)
    assert(m1 == m2)
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

function lVector:width()
  local width = cVector.width(self._base_vec)
  return width
end

function lVector:ref_count()
  local ref_count = cVector.ref_count(self._base_vec)
  return ref_count
end

function lVector:memo_len()
  local memo_len = cVector.memo_len(self._base_vec)
  return memo_len
end

function lVector:max_num_in_chunk()
  local max_num_in_chunk = cVector.max_num_in_chunk(self._base_vec)
  return max_num_in_chunk
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
  return num_chunks
end

function lVector:num_elements()
  local num_elements = cVector.num_elements(self._base_vec)
  return num_elements
end

function lVector:name()
  local name = cVector.name(self._base_vec)
  if ( not name ) then return "anonymous", "no name" end 
  return name
end

function lVector:is_error()
  local x, y = cVector.is_error(self._base_vec)
  if ( type(x) == "boolean" ) then return x else return nil end 
end

function lVector:set_error()
  local status = cVector.set_error(self._base_vec)
  return self
end

function lVector:set_name(name)
  if ( type(name) == "nil" ) then name = "" end 
  assert(type(name) == "string")
  local status = cVector.set_name(self._base_vec, name)
  if ( self._nn_vec ) then 
    local nn_vector = self._nn_vec
    local status = cVector.set_name(nn_vector._base_vec, "nn_" .. name)
  end
  return self
end
function lVector:drop(level)
  assert(type(level) == "number")
  assert(cVector.drop_l1_l2(self._base_vec, level))
  if ( self._nn_vec ) then 
    assert(self:has_nulls())
    local nn_vector = self._nn_vec
    assert(type(nn_vector) == "lVector")
    assert((nn_vector:qtype() == "BL") or (nn_vector:qtype() == "B1"))
    assert(cVector.drop_l1_l2(nn_vector._base_vec, level))
  end
  return self
end
function lVector:persist()
  local status = cVector.persist(self._base_vec)
  return self
end
function lVector:eov()
  local status = cVector.eov(self._base_vec)
  local nn_vector = self._nn_vec
  if ( nn_vector ) then
    assert(type(nn_vector) == "lVector")
    if ( nn_vector ) then 
      status = cVector.eov(nn_vector._base_vec) 
    end 
  end
  -- TODO P1 Should we get rid of chunk_num now ?
  self._generator = nil -- IMPORTANT, we no longer have a generator 
  return self
end
function lVector:drop_nulls()
  if ( not self._nn_vec ) then return self end -- quiet quick return
  -- Following is Too aggressive. 
  -- Somebody else may be using it using get_nulls()
  -- local nn_vector = self._nn_vec; nn_vector:delete() 
  self._nn_vec = nil
  return self
end

function lVector:has_nulls()
  if ( self._nn_vec ) then return true else return false end 
end

function lVector:is_lma()
  local b_is_lma = cVector.is_lma(self._base_vec)
  assert(type(b_is_lma) == "boolean")
  return b_is_lma
end

function lVector:is_eov()
  local b_is_eov = cVector.is_eov(self._base_vec)
  assert(type(b_is_eov) == "boolean")
  return b_is_eov
end

function lVector:nop()
  local status = cVector.nop(self._base_vec)
  -- TODO P1 THINK assert(type(status) == "boolean")
  return status
end

local function chnk_clone(v) -- for case when no lma
  -- TODO Need to support lazy evaluation of ouptut vector 
  -- Currently, we are generating entire vector here 
  assert(type(v) == "lVector")
  local vargs = {}
  vargs.qtype            = v:qtype() 
  vargs.width            = v:width() 
  vargs.max_num_in_chunk = v:max_num_in_chunk() 
  vargs.has_nulls        = v:has_nulls() 

  vargs.memo_len = v:memo_len()
  assert(vargs.memo_len == -1)

  local b, n = v:is_killable(); assert(b == false); assert(n == 0)
  vargs.num_lives_kill = 0

  local b, n = v:is_early_freeable(); assert(b == false); assert(n == 0)
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
  -- current limitation, clone needs lma, cannot handle chunks 
  if ( not self:is_lma() ) then
    return chnk_clone(self)
  end
  local vargs = {}
  local file_name, _ = self:file_info()
  -- make a unique name 
  local t = cutils.rdtsc()
  t = t - (math.floor(t/100000000)*100000000)
  vargs.file_name = file_name .. tostring(t)
  assert(cutils.copyfile(file_name, vargs.file_name))
  --=================
  vargs.name = "clone_" 
  if ( self:name() ) then vargs.name = vargs.name .. self:name() end 
  vargs.qtype = self:qtype()
  vargs.max_num_in_chunk = self:max_num_in_chunk()
  vargs.num_elements = self:num_elements()
  local z = lVector(vargs)

  -- clone the nn vector if there is one 
  if ( self:has_nulls() ) then 
    local nn_vector = assert(self._nn_vec)
    local nn_z = lVector.clone(nn_vector) -- TODO P1 Check if this works
    z:set_nulls(nn_z)
  end
  return z
end

function lVector:is_persist()
  local b_is_persist = cVector.is_persist(self._base_vec)
  assert(type(b_is_persist) == "boolean")
  return b_is_persist
end

function lVector:has_gen()
  if ( self._generator ) then return true  else return false end 
end

--=================================================
function lVector:uqid()
  local uqid = cVector.uqid(self._base_vec)
  assert(type(uqid) == "number")
  return uqid
end
--=================================================
function lVector:tbsp()
  local tbsp = cVector.tbsp(self._base_vec)
  assert(type(tbsp) == "number")
  return tbsp
end
--=================================================
function lVector:memo_len()
  return self._memo_len
end
--=================================================
function lVector:qtype()
  return self._qtype
end
--=================================================
function lVector:nn_qtype()
  if ( not self._nn_vec ) then return nil end 
  return self._nn_vec:qtype()
end
--=================================================
function lVector.new(args)
  local vector = setmetatable({}, lVector)
  vector._meta = {} -- for meta data stored in vector
  vector._is_dead = false -- will be set to true upon deletion
  assert(type(args) == "table")
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
    vector._max_num_in_chunk = cVector.max_num_in_chunk(vector._base_vec)
    vector._memo_len        = cVector.memo_len(vector._base_vec)
    vector._qtype           = cVector.qtype(vector._base_vec)
    -- If vector has nulls, do following 
    if ( args.nn_uqid ) then 
      local nn_uqid = args.nn_uqid
      assert(type(nn_uqid) == "number")
      assert(nn_uqid > 0)
      vector._nn_vec = assert(cVector.rehydrate({ uqid = nn_uqid}))
      vector._nn_vec._parent = vector -- set your parent 
    end 
    vector:persist(false) -- IMPORTANT
    return vector 
  end
  --=================================================

  vector._siblings = {} -- no conjoined vectors
  vector._chunk_num = 0 -- next chunk to ask for 
  if ( args.gen ) then vector._generator = args.gen end 
  --=================================================
  assert(type(args.qtype) == "string")
  vector._qtype = args.qtype
  --=================================================
  if ( args.max_num_in_chunk ) then 
    vector._max_num_in_chunk = args.max_num_in_chunk
  else
    vector._max_num_in_chunk = qcfg.max_num_in_chunk
    -- NOTE: Following needed for cVector.add*
    args.max_num_in_chunk = vector._max_num_in_chunk 
  end
  assert(type(vector._max_num_in_chunk) == "number")
  assert(vector._max_num_in_chunk > 0)
  assert( math.floor(vector._max_num_in_chunk / 64 ) == 
          math.ceil(vector._max_num_in_chunk / 64 ) )
  --=================================================
  if ( args.memo_len ) then 
    vector._memo_len = args.memo_len
  else
    vector._memo_len = qcfg.memo_len
    -- NOTE: Following needed for cVector.add*
    args.memo_len = vector._memo_len 
  end
  assert(type(vector._memo_len) == "number")
  --=================================================
  if ( args.num_lives_kill ) then 
    assert(type(args.num_lives_kill) == "number" )
    assert(args.num_lives_kill >= 0)
  else
    args.num_lives_kill = qcfg.num_lives_kill
  end
  if ( args.num_lives_kill == 0 ) then 
    args.is_killable = false
  else
    args.is_killable = true
  end
  --=================================================
  if ( args.num_lives_free ) then 
    assert(type(args.num_lives_free) == "number" )
    assert(args.num_lives_free >= 0)
  else
    args.num_lives_free = qcfg.num_lives_free
  end
  if ( args.num_lives_free == 0 ) then 
    args.is_early_freeable = false
  else
    args.is_early_freeable = true
  end
  --=================================================
  vector._base_vec = assert(cVector.add1(args))
  if ( args.has_nulls ) then 
    -- assemble args for nn Vector 
    local nn_args = {}
    local nn_qtype = "BL"
    if ( args.nn_qtype ) then 
      assert(type(args.nn_qtype) == "string")
      nn_qtype = args.nn_qtype
      assert((nn_qtype == "B1") or (nn_qtype == "BL"))
    end
    nn_args.qtype = nn_qtype
    if ( args.name ) then 
      nn_args.name = "nn_" .. args.name 
    end
    if ( args.max_num_in_chunk ) then 
      nn_args.max_num_in_chunk  = args.max_num_in_chunk 
    end
    if ( args.memo_len ) then 
      nn_args.memo_len  = args.memo_len 
    end

    nn_args.is_killable  = args.is_killable 
    nn_args.num_lives_kill  = args.num_lives_kill 

    nn_args.is_early_freeable  = args.is_early_freeable 
    nn_args.num_lives_free  = args.num_lives_free 
    ----------------------------------- 
    local nn_vector = setmetatable({}, lVector)
    nn_vector._base_vec = assert(cVector.add1(nn_args))
    nn_vector._qtype = nn_qtype
    nn_vector._parent = vector -- set parent for nn vector 
    nn_vector._chunk_num = 0

    vector._nn_vec = nn_vector 
  end 
  --=================================================
  return vector
end
function lVector:memo(memo_len)
  if ( type(memo_len) == "nil" ) then 
    memo_len = qcfg.memo_len
  end
  assert(type(memo_len == "number"))
  -- cannot memo once vector has elements in it 
  if ( self:num_elements() > 0 ) then return nil end 
  assert(cVector.set_memo(self._base_vec, memo_len))
  self._memo_len = memo_len
  if ( self._nn_vec ) then 
    local nn_vector = assert(self._nn_vec)
    assert(cVector.set_memo(nn_vector._base_vec, memo_len))
    nn_vector._memo_len = memo_len
  end
  return self
end

-- In first implementation, get_nulls() would also drop_nulls()
-- Now, you have to drop_nulls() explicitly if you want to
function lVector:get_nulls() 
  -- must have an nn_vec currently
  if ( not self._nn_vec ) then 
    print("No nn vector, returning nil") 
    return nil 
  end 
  local x = assert(self._nn_vec) 
  -- This was old behavior self._nn_vec = nil
  return x
end

function lVector:nn_qtype() 
  if ( not self._nn_vec ) then 
    print("No nn vector, returning nil"); return nil 
  end 
  local x = assert(self._nn_vec) 
  return x:qtype()
end

function lVector:set_nulls(nn_vec)
  assert(not self._nn_vec) -- must not have an nn_vec currently
  assert(self:is_eov()) -- -- TODO P1 MUST IT BE EOV? 
  --===============
  assert(type(nn_vec) == "lVector")
  assert(nn_vec:has_nulls() == false) -- nn cannot have nulls
  assert(nn_vec:is_eov()) -- -- TODO P1 MUST IT BE EOV ?? 
  assert(nn_vec:num_elements() == self:num_elements()) -- sizes must match
  assert((nn_vec:qtype() == "BL") or (nn_vec:qtype() == "BL"))

  self._nn_vec = nn_vec
  return self 
end

function lVector:put1(sclr, nn_sclr)
  --========================
  assert(type(sclr) == "Scalar")
  --========================
  -- nn_sclr can be provided only if vector has nulls
  if ( type(nn_sclr) ~= "nil" ) then assert(self._nn_vec) end
  -- if vector has nulls, nn_sclr must be provided
  if ( self._nn_vec ) then assert(type(nn_sclr) == "Scalar") end
  -- if nn_sclr is provided it must be BL Scalar
  if ( type(nn_sclr) ~= "nil" ) then
    assert(type(nn_sclr) == "Scalar")
    assert(nn_sclr:qtype() == "BL") 
  end
  --========================
  -- TODO P3 Take out debugging checks belo
  local n1 = self:num_elements() 
  assert(cVector.put1(self._base_vec, sclr))
  local n2 = self:num_elements() 
  assert(n1+1 == n2)
  local nn_vector = self._nn_vec
  if ( nn_vector ) then 
    local nn_n1 = nn_vector:num_elements() 
    assert(cVector.put1(nn_vector._base_vec, nn_sclr))
    local nn_n2 = nn_vector:num_elements() 
    assert(nn_n1+1 == nn_n2)
  end
end

function lVector:putn(col, n, nn_col)
  --========================
  assert(type(col) == "CMEM")
  --========================
  if ( type(n) == "nil" ) then n = 1 end
  assert(type(n) == "number"); assert(n > 0)
  --========================
  -- nn_col can be provided only of vector has nulls
  if ( type(nn_col) ~= "nil" ) then assert(self._nn_vec) end
  -- if vector has nulls, nn_col must be provided 
  if ( self._nn_vec ) then assert(nn_col) end 
  -- if nn_col, then it must be CMEM 
  if ( nn_col ) then assert(type(nn_col) == "CMEM") end
  --========================
  assert(cVector.putn(self._base_vec, col, n))
  if ( self._nn_vec ) then 
    local nn_vector = assert(self._nn_vec)
    local nn_vec = nn_vector._base_vec
    assert(cVector.putn(nn_vec, nn_col, n))
  else
    assert(nn_col == nil)
  end
end

function lVector:put_chunk(c, n, nn_c)
  assert(type(c) == "CMEM")
  assert(type(n) == "number")
  assert(n > 0) -- cannot put empty chunk 
  assert(cVector.put_chunk(self._base_vec, c, n))
  self._chunk_num = self._chunk_num + 1 
  if ( self._nn_vec ) then 
    assert(type(nn_c) == "CMEM")
    local nn_vector = assert(self._nn_vec)
    nn_vector._chunk_num = nn_vector._chunk_num + 1 
    local nn_vec = nn_vector._base_vec
    assert(cVector.put_chunk(nn_vec, nn_c, n))
    assert(self._chunk_num == nn_vector._chunk_num)
  else
    -- TODO THINK Why are we getting nn_c if vector does not have nulls?
    if ( type(nn_c) == "CMEM" ) then
      print("STRANGE. " .. self:name())
      nn_c:delete() -- not needed
    else
      assert(nn_c == nil)
    end
  end
end

function lVector:get1(elem_idx)
  local nn_sclr
  assert(type(elem_idx) == "number")
  if (elem_idx < 0) then return nil end
  local sclr = cVector.get1(self._base_vec, elem_idx)
  if ( type(sclr) ~= "nil" ) then assert(type(sclr) == "Scalar") end
  local nn_vector = self._nn_vec
  if ( nn_vector and sclr ) then
    assert(type(nn_vector) == "lVector")
    nn_sclr = cVector.get1(nn_vector._base_vec, elem_idx)
    assert(type(nn_sclr) == "Scalar") 
    assert(nn_sclr:qtype() == "BL") 
  end
  return sclr, nn_sclr
end

function lVector:unget_chunk(chnk_idx)
  assert(cVector.unget_chunk(self._base_vec, chnk_idx))
  if ( self._nn_vec ) then 
    local nn_vector = self._nn_vec
    assert(type(nn_vector) == "lVector")
    assert((nn_vector:qtype() == "B1") or (nn_vector:qtype() == "BL"))
    assert(cVector.unget_chunk(nn_vector._base_vec, chnk_idx))
  end
end

function lVector:get_chunk(chnk_idx)
  assert(type(chnk_idx) == "number")
  assert(chnk_idx >= 0)
  local to_generate 
  if ( self:is_eov() ) then
    to_generate = false
  else
    if ( chnk_idx < self._chunk_num ) then 
      to_generate = false
    elseif ( chnk_idx == self._chunk_num ) then 
      to_generate = true
    else
      error("")
    end
  end
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
  if ( to_generate ) then -- IF TO GENERATE
    if ( not self._generator ) then 
      print("ERROR: Expected generator for " .. self:name())
      return 0, nil 
    end 
    local num_elements, buf, nn_buf = self._generator(self._chunk_num)
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
    if ( num_elements < self._max_num_in_chunk ) then 
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
    -- release old chunks
    -- NOTE that memo_len == 0 is meanignless 
    -- because we always keep the last chunk generated
    if ( qcfg.debug ) then 
      if ( ( self._memo_len >= 0 ) and ( num_elements > 0 ) ) then
        -- Note the extra -1 below. This is to account for
        -- the put_chunk above which would have incremented self._chunk_num
        local chunk_to_release = self._chunk_num - 1 - self._memo_len - 1 
        if ( chunk_to_release >= 0 ) then 
          local is_found = 
            cVector.chunk_delete(self._base_vec, chunk_to_release)
          assert(is_found == false)
        end
      end
    end
    --===========================
    if ( ( self._siblings ) and ( #self._siblings > 0 ) ) then 
      assert(type(self._siblings) == "table")
      for _, v in ipairs(self._siblings) do
        assert(type(v) == "lVector") assert(type(v) == "lVector")
--[[
        print("Vector " .. self:name(), " requesting chunk " .. chnk_idx .. 
          " for sibling", v:name())
--]]
        local x, y, z = v:get_chunk(chnk_idx)
        assert(x == num_elements)
        if ( x < self._max_num_in_chunk ) then 
          -- print("Sibling EOV for " .. v:name())
          v:eov()  -- vector is at an end 
        end
        -- following because we aren't really consuming the chunk
        -- we are just getting it 
        v:unget_chunk(chnk_idx)
        if ( qcfg.debug ) then 
          -- Checks if chunks that should have been deleted because of
          -- memo_len, have in fact been deleted 
          if ( ( v:memo_len() >= 0 ) and ( v:num_elements() > 0 ) ) then
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
    if ( self._nn_vec ) then 
      local nn_vector = self._nn_vec
      assert(nn_vector:chnk_incr_num_readers(chnk_idx))
    end
    -- print("Returning " .. num_elements .. " for " .. self:name())
    -- TODO print("XXX", chnk_idx, self:num_readers(chnk_idx), self:name())
    -- TODO assert(self:num_readers(chnk_idx) == 1)
    return num_elements, buf, nn_buf
  else -- ELSE OF IF TO GENERATE
    -- print(" Archival chunk for " .. self:name(), self._chunk_num)
    if ( qcfg.debug ) then self:check(false) end 
    local nn_x, nn_n
    local x, n = cVector.get_chunk(self._base_vec, chnk_idx)
    if ( x == nil ) then return 0, nil, nil end 
    if ( self._nn_vec ) then 
      local nn_vector = self._nn_vec
      if ( n == 29316 ) then
        self:nop()
        nn_vector:nop()
      end
      print("A getting for ", self:name(), n)
      print("B getting for ", nn_vector:name())
      nn_x, nn_n = cVector.get_chunk(nn_vector._base_vec, chnk_idx)
      print("gotten  for ", nn_vector:name())
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
  if ( self:is_eov() ) then return self end 
  repeat
    local num_elements, buf, nn_buf = self:get_chunk(self._chunk_num)
    if ( nn_buf ) then assert(type(nn_buf) == "CMEM") end 
    if (    buf ) then assert(type(   buf) == "CMEM") end 
    assert(type(num_elements) == "number")
    -- this unget needed because get_chunk increments num readers 
    -- and the eval doesn't actually get the chunk for itself
    -- The -1 below is important. This is because get_chunk would have 
    -- called put_chunk which would have incremented chunk_num
    -- TODO THINK. I added ( self._chunk_num > 0 ) 
    -- to handle the zero element array case. Consider this caefully
    local chunk_to_unget = self._chunk_num - 1
    if ( num_elements == 0 ) then
      -- nothing to unget
    else
      -- print("Ungetting " .. self._chunk_num .. " for " .. self:name())
      assert(cVector.unget_chunk(self._base_vec, chunk_to_unget))
      if ( self._nn_vec ) then 
        local nn_vector = self._nn_vec
        assert(cVector.unget_chunk(nn_vector._base_vec, chunk_to_unget))
      end
    end
  until ( num_elements ~= self._max_num_in_chunk ) 
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
    self._gen = nil -- generation all done => no generator needed
  end
  --]]
  if ( qcfg.debug ) then self:check() end
  return self
end

function lVector:pr(opfile, lb, ub, format)
  -- Note that nn_vec can be number or Vector
  local nn_vector = self._nn_vec
  local nn_vec = 0 -- => no null vector
  if ( nn_vector ~= nil ) then
    assert(type(nn_vector) == "lVector")
    nn_vec = nn_vector._base_vec
    assert(type(nn_vec) == "Vector")
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
  -- assert(cVector.pr(self._base_vec, self._nn_vec, opfile, lb, ub))
  assert(cVector.pr(self._base_vec, nn_vec, opfile, lb, ub, format))
  return true
end
--========================================================
function lVector:get_meta(key)
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
  assert(type(key) == "string")
  assert(value)
  if ( not self._meta ) then self._meta = {} end 
  self._meta[key] = value
  return self
end
--========================================================

function lVector.null()
  return cVector.null()
end

-- DANGEROUS FUNCTION. Use with great care. This is because you 
-- want Lua to do garbage collection with its reference counting.
-- Else, you could end up in the followint situation
-- x = lVector(....) -- create  a vector pointed to by x 
-- y = x 
-- x:delete()
-- y is left hanging to an empty vector -- dangerous situation

lVector.__gc = function (vec)
  if ( vec._is_dead ) then
    -- print("Vector already dead.")
    return false
  end 
  local vname = ifxthenxelsey(vec:name(), "anonymous_" .. vec:uqid())
  -- print("GC CALLED on " .. vname)
  --=========================================
  if ( vec:has_nulls() ) then 
    local nn_vector = vec._nn_vec
    assert(type(nn_vector) == "lVector")
    if ( nn_vector._is_dead ) then 
      -- print("Vector already dead.")
    else
      local vname = ifxthenxelsey(nn_vector:name(), "anonymous_" .. 
        nn_vector:uqid())
      -- print("GC CALLED on nn " .. vname)
      -- local x = cVector.delete(nn_vector._base_vec)
      -- TODO Why is x == false?
      local x = cVector.delete(nn_vector._base_vec)
      nn_vector._is_dead = true 
      vec._nn_vec = nil
    end
  end
  vec._is_dead = true
  return cVector.delete(vec._base_vec)
end

function lVector:delete()
  local vname = ifxthenxelsey(self:name(), "anonymous:" .. self:uqid())
  -- print("DELETE CALLED on " .. vname)
  if ( self:uqid() == 7 ) then
    self:nop()
  end
  if ( self._parent ) then
    print("Need to kill parent, not me") -- TODO P1 Think about this
    return false
  end
  if ( self._is_dead ) then
    print("Vector already dead.")
    return false
  end 
  --=========================================
  if ( self:has_nulls() ) then 
    local nn_vector = self._nn_vec
    assert(type(nn_vector) == "lVector")
    local vname = ifxthenxelsey(nn_vector:name(), "anonymous:" .. nn_vector:uqid())
    -- print("DELETE CALLED on nn of " .. vname)
    if ( nn_vector._is_dead ) then 
      -- print("nn Vector already dead.")
    else
      -- local x = cVector.delete(nn_vector._base_vec)
      -- TODO Why is x == false?
      local x = cVector.delete(nn_vector._base_vec)
      nn_vector._is_dead = true
    end
  end
  self._is_dead = true
  return  cVector.delete(self._base_vec)
end


function lVector:siblings()
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

function lVector:add_sibling(v)
  assert(type(v) == "lVector")
  if ( not self._siblings ) then 
    self._siblings = {}
  end
  assert(type(self._siblings) == "table")
  self._siblings[#self._siblings+1] = v
  return self
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
        v1:add_sibling(v2)
        -- print("Adding " .. v2:name() .. " as sibling of " .. v1:name())
      end
    end
  end
end
--==================================================
function lVector:append(x)
  assert(type(x) == "lVector")
  --=================
  assert(x:is_eov())
  if ( not x:is_lma() ) then 
    x:chunks_to_lma()
  end
  assert(x:is_lma())
  --=================
  assert(self:is_eov())
  if ( not self:is_lma() ) then 
    self:chunks_to_lma()
  end
  assert(self:is_lma())
  --=================
  if ( self:has_nulls() ) then assert(x:has_nulls()) end 
  if ( not self:has_nulls() ) then assert(not x:has_nulls()) end 
  --=================

  assert(cVector.append(self._base_vec, x._base_vec))
  if ( self:has_nulls() ) then 
    local nn_vector = self._nn_vec
    local nn_x = x._nn_vec
    assert(cVector.append(nn_vector._base_vec, nn_x._base_vec))
  end
  return  true -- TODO P0 MAJOR HACK 
end
-- REGARDING early free. This was motivated by the following case
-- Say you do z := x where y.
-- since we produce z in full chunks, we might consume n >1 chunks of x, y
-- before we produce a full chunk of z. 
-- So, we cannot x:memo(n) since we don't know what n would be 
-- When early_free() is called on a vector which is early_freeable()
-- we delete all but the last chunk
--==================================================
function lVector:early_free() -- equivalent of kill() 
  assert(cVector.early_free(self._base_vec))
  return self
end
--==================================================
function lVector:is_early_freeable() 
  local b_is_early_free, num_lives_free, num_early_freed = 
    cVector.get_num_lives_free(self._base_vec)
  assert(type(b_is_early_free) == "boolean")
  assert(type(num_lives_free) == "number")
  assert(type(num_early_freed) == "number")
  return b_is_early_free, num_lives_free, num_early_freed
end
--==================================================
function lVector:early_freeable(num_lives) -- equivalent of killable()
  assert(type(num_lives) == "number")
  assert(cVector.set_num_lives_free(self._base_vec, num_lives))
  return self
end
--==================================================
function lVector:self()
  return self._base_vec
end
--==================================================
function lVector:chunks_to_lma()
  -- TODO VERIFY THAT THIS IS IDEMPOTENT. 
  assert(cVector.chnks_to_lma(self._base_vec))
  if ( self._nn_vec ) then 
    local nn_vector = assert(self._nn_vec)
    assert(type(nn_vector) == "lVector")
    assert(( nn_vector:qtype() == "B1" ) or ( nn_vector:qtype() == "BL" ))
    assert(cVector.chnks_to_lma(nn_vector._base_vec))
  end
  return self
end
--==================================================
function lVector:lma_to_chunks()
  -- TODO VERIFY THAT THIS IS IDEMPOTENT. 
  assert(cVector.lma_to_chnks(self._base_vec))
  if ( self._nn_vec ) then 
    local nn_vector = assert(self._nn_vec)
    assert(type(nn_vector) == "lVector")
    assert(( nn_vector:qtype() == "B1" ) or ( nn_vector:qtype() == "BL" ))
    assert(cVector.lma_to_chnks(nn_vector._base_vec))
  end
  return self
end
--==================================================
function lVector:get_lma_read()
  local x, nn_x
  local x = assert(cVector.get_lma_read(self._base_vec))
  if ( self._nn_vec ) then 
    local nn_vector = assert(self._nn_vec)
    assert(type(nn_vector) == "lVector")
    assert(( nn_vector:qtype() == "B1" ) or ( nn_vector:qtype() == "BL" ))
    nn_x = assert(cVector.get_lma_read(nn_vector._base_vec))
  end
  return x, nn_x, self:num_elements()
end
--==================================================
function lVector:get_lma_write()
  local x, nn_x
  local x = assert(cVector.get_lma_write(self._base_vec))
  if ( self._nn_vec ) then 
    local nn_vector = assert(self._nn_vec)
    assert(type(nn_vector) == "lVector")
    assert(( nn_vector:qtype() == "B1" ) or ( nn_vector:qtype() == "BL" ))
    nn_x = assert(cVector.get_lma_write(nn_vector._base_vec))
  end
  -- FOLLOWING IS SUPER IMPORTANT 
  -- If there are chunks, we need to delete them 
  -- This is because the request for write access => changes to lma file
  -- Then, the chunks are no longer consistent.
  self:drop_mem(1)
  self:drop_mem(2)
  if ( self._nn_vec ) then 
    local nn_vector = assert(self._nn_vec)
    local nn_vec = nn_vector._base_vec
    assert(cVector.drop_mem(nn_vec, 1))
    assert(cVector.drop_mem(nn_vec, 2))
  end 
  return x, nn_x, self:num_elements()
end
--==================================================
function lVector:unget_lma_read()
  assert(cVector.unget_lma_read(self._base_vec))
  if ( self._nn_vec ) then 
    local nn_vector = assert(self._nn_vec)
    assert(type(nn_vector) == "lVector")
    assert(( nn_vector:qtype() == "B1" ) or ( nn_vector:qtype() == "BL" ))
    assert(cVector.unget_lma_read(nn_vector._base_vec))
  end
  return self
end
--==================================================
function lVector:unget_lma_write()
  assert(cVector.unget_lma_write(self._base_vec))
  if ( self._nn_vec ) then 
    local nn_vector = assert(self._nn_vec)
    assert(type(nn_vector) == "lVector")
    assert(( nn_vector:qtype() == "B1" ) or ( nn_vector:qtype() == "BL" ))
    assert(cVector.unget_lma_write(nn_vector._base_vec))
  end
  return self
end
--==================================================
-- use this function to set kill-ability of vector 
function lVector:killable(val)
  assert(type(val) == "number")
  assert(cVector.set_num_lives_kill(self._base_vec, val))
  if ( self._nn_vec ) then 
    local nn_vector = self._nn_vec
    assert(cVector.set_num_lives_kill(nn_vector._base_vec, val))
  end
  return self
end
--==================================================
function lVector:is_killable()
  local b_is_killable, num_lives_kill = 
    cVector.get_num_lives_kill(self._base_vec)
  assert(type(b_is_killable) == "boolean")
  assert(type(num_lives_kill) == "number")
  return b_is_killable, num_lives_kill
end
--==================================================
-- will delete the vector *ONLY* if marked as is_killable; else, NOP
function lVector:kill()
  local nn_success
  print("Lua received kill for " .. self:name())
  local success = cVector.kill(self._base_vec)
  if ( self._nn_vec ) then 
    local nn_vector = assert(self._nn_vec)
    print("Lua received kill for nn vector " .. nn_vector:name())
    if ( nn_vector._parent ) then 
      print("kill parent not me ") -- TODO P1 need to understand this case
      nn_success = false
    else
      nn_success = cVector.kill(nn_vector._base_vec)
    end
  end
  return success, nn_success
end
--==================================================
function lVector:prefetch(chnk_idx)
  assert(type(chnk_idx) == "number")
  local nn_x, nn_n
  local exists, status = cVector.prefetch(self._base_vec, chnk_idx)
  
  if ( exists and self._nn_vec ) then 
    local nn_vector = self._nn_vec
    local nn_exists, status=cVector.prefetch(nn_vector._base_vec, chnk_idx)
    assert(status == 0)
    assert(nn_exists) -- if chunk exists for base, must exist for nn 
  end
  return exists
  -- exists tells us whether such a chunk existed 
  -- Ideally, we want prefetch to be just an advisory i.e.,
  -- if there is not enough memory, then it should fail silently
  -- TODO P3: We have not implemented those smarts. 
  -- So, if the chunk exists, it will be loaded into memory 
end
--==================================================
function lVector:unprefetch(chnk_idx)
  assert(type(chnk_idx) == "number")
  local nn_x, nn_n
  cVector.unprefetch(self._base_vec, chnk_idx)
  if ( self._nn_vec ) then 
    local nn_vector = self._nn_vec
    cVector.prefetch(nn_vector._base_vec, chnk_idx)
  end
end
--==================================================
function lVector:drop_mem(level, chnk_idx)
  assert(type(level) == "number")
  if ( not chnk_idx ) then chnk_idx = -1 end
  assert(type(chnk_idx) == "number")
  local rslt = cVector.drop_mem(self._base_vec, level, chnk_idx)
  local nn_rslt
  if ( self._nn_vec ) then 
    local nn_vector = self._nn_vec
    local nn_rslt = cVector.drop_mem(nn_vector._base_vec, level, chnk_idx)
  end
  return rslt, nn_rslt
end
--==================================================
function lVector:make_mem(level, chnk_idx)
  assert(type(level) == "number")
  if ( not chnk_idx ) then chnk_idx = -1 end
  assert(type(chnk_idx) == "number")
  local rslt = cVector.make_mem(self._base_vec, level, chnk_idx)
  local nn_rslt
  if ( self._nn_vec ) then 
    local nn_vector = self._nn_vec
    local nn_rslt = cVector.make_mem(nn_vector._base_vec, level, chnk_idx)
  end
  return rslt, nn_rslt
end
--==================================================
function lVector:cast(qtype) -- DANGEROUS, USE WITH CAUTION
  assert(type(qtype) == "string")
  assert(cVector.cast(self._base_vec, qtype))
  self._qtype = qtype
  return self
end
--==================================================
function lVector:file_info() 
  local file_name, sz = cVector.file_info(self._base_vec)
  if ( file_name == ffi.NULL ) then return nil, 0 end 
  return file_name, sz
end
--==================================================
return lVector
