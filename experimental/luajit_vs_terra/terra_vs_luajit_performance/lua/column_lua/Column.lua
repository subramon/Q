local plpath = require("pl.path")
local Column = {}
Column.__index = Column
local q_core = require 'q_core'
local Vector = require "Vector"
local DestructorLookup = {}

--TODO move to utils
local function clone (t) -- deep-copy a table
   if type(t) ~= "table" then return t end
   local meta = getmetatable(t)
   local target = {}
   for k, v in pairs(t) do
      if type(v) == "table" then
         target[k] = clone(v)
      else
         target[k] = v
      end
   end
   setmetatable(target, meta)
   return target
end

function clone (t) -- deep-copy a table
   if type(t) ~= "table" then return t end
   local meta = getmetatable(t)
   local target = {}
   for k, v in pairs(t) do
      if type(v) == "table" then
         target[k] = clone(v)
      else
         target[k] = v
      end
   end
   setmetatable(target, meta)
   return target
end




setmetatable(Column, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})

function Column.destructor(data)
   -- Works with Lua but not luajit so adding a little hack
   if type(data) == type(Column) then
      q_core.free(data.destructor_ptr)
   else
      -- local tmp_slf = DestructorLookup[data]
      DestructorLookup[data] = nil
      q_core.free(data)
   end
end

Column.__gc = Column.destructor

local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
   local otype = original_type( obj )
   if  otype == "table" and getmetatable( obj ) == Column then
      return "Column"
   end
   return otype
end

function Column.new(arg)
   local column = setmetatable({}, Column)
   column.meta = {}
   column.destructor_ptr = q_core.malloc(1, Column.destructor) -- Destructor hack for luajit
   DestructorLookup[column.destructor_ptr] = column
   assert(type(arg) == "table", "Called constructor with incorrect arguements")
   if arg.gen ~= nil then
      column.gen = arg.gen
      column.vec = Vector{field_type=arg.field_type, write_vector=true}
   else
      --assert(arg.field_type ~= nil, "Need a field type for a read or write column")
      local vec_args = clone(arg)
      vec_args.nn = nil
      vec_args.nn_filename = nil
      column.vec = Vector(vec_args)
   end
   if arg.nn then
      if column.gen ~= nil then
         column.nn_vec = Vector{field_type="B1", write_vector=true}
      else
         local nn_vec_args = clone(arg)
         nn_vec_args.nn = nil
         nn_vec_args.filename = nn_vec_args.nn_filename or (nn_vec_args.filename .. "_nn")
         nn_vec_args.field_type= "B1"
         column.nn_vec = Vector(nn_vec_args)
      end
   end
   return column
end

function Column:length()
   return self.vec:length()
end

function Column:fldtype()
   return self.vec:fldtype()
end

function Column:has_nulls()
   if self.nn_vec == nil  then
      return true
   else
      return false
   end
end

function Column:sz()
   --size of each entry
   --if self.nn_vec ~= nil then
   --    assert(self.vec:sz() == self.nn_vec:sz(), "Null vector and vector should have the same length")
   --end
   return self.vec:sz()
end

function Column:memo(bool)
   local res = self.vec:memo(bool)
   if self.nn_vec ~= nil then
      assert(res == self.nn_vec(bool))
   end
   return res
end

function Column:ismemo()
   return self.vec:ismemo()
end

function Column:last_chunk()
   local vec_num = self.vec:last_chunk()
   local nn_num = nil
   if self.nn_vec ~= nil then
      nn_num = self.nn_vec:last_chunk()
      assert(vec_num == nn_num, "Position of both vectors has to be the same")
      assert(vec ~= nn_vec, "The vectors are different")
   end
   return vec_num
end

function Column:materialized()
   return self.vec:materialized()
end

function Column:get_element(num)
   if self.nn_vec ~= nil and self.nn_vec:get_element(num) == q_core.NULL then
      return q_core.NULL
   else
      return self.vec:get_element(num)
   end
end
function Column:chunk(num)
   local chunk_num = self.vec:last_chunk()
   assert(type(num) == "number", "Require a number for chunk number")
   if self:materialized() ~= true and self.gen ~= nil and (chunk_num == nil or num == chunk_num + 1 ) then
      -- now the column has a generator to manage
      local status, size, vec_chunk, nn_vec_chunk = coroutine.resume(self.gen)
      if status  and size ~= nil then
         self.vec:put_chunk(vec_chunk, size)
         if self.nn_vec ~= nil then
            self.nn_vec:put_chunk(nn_vec_chunk, size)
            -- TODO Assert for else is removed for perf
         end
      else -- Basically means that the vector is exhausted
        size, vec_chunk, nn_vec_chunk = 0, nil ,nil 
      end
      if coroutine.status(self.gen) == "dead" then
         self.vec:eov()
         if self.nn_vec ~= nil then
            self.nn_vec:eov()
         end
         self.gen= nil
      end
      return size, vec_chunk, nn_vec_chunk

   elseif chunk_num == nil or num <= chunk_num then
      local vec, vec_size = self.vec:chunk(num)
      local nn_vec, nn_vec_size
      if self.nn_vec ~= nil then
         nn_vec, nn_vec_size = self.nn_vec:chunk(num)
         assert(vec_size == nn_vec_size, "Size of the chunks from vectors and null vectors should be the same")
      end
      return vec_size, vec, nn_vec
   else
      error("Bad index" .. tostring(num))
   end
end

function Column:put_chunk(length, chunk, nn_chunk)
   self.vec:put_chunk(chunk, length)
   if self.nn_vec ~= nil then
      self.nn_vec:put_chunk(nn_chunk, length)
   end
end

function Column:eov()
   self.vec:eov()
   if self.nn_vec ~= nil then
      self.nn_vec:eov()
   end
end

--g_valid_meta = {}
-- TODO NOTE Currently we allow any meta data to be set (think about it)
function Column:get_meta(index)
   -- assert(g_valid_meta[index] ~= nil, "Invalid key given: ".. index)
   return self.meta[index]
end

function Column:set_meta(index, val)
   -- assert(g_valid_meta[index] ~= nil, "Invalid key given: ".. index)
   self.meta[index] = val
end

-- TODO Serious - Do not perform this operation when multiple people share a column
-- Make it ref counted in future
function Column:delete_nn()
   if self.nn_vec ~= nil then
      self.nn_vec:delete()
      self.nn_vec = nil
   end
end

function Column:chunk_size()
   return self.vec.chunk_size
end

function Column:wrap()
   return coroutine.create(function()
      local i = 0
      local status = true
      while status do
         status, length, chunk, nn_chunk = self:chunk(i)
         if status then
            coroutine.yield(status, length, chunk, nn_chunk)
            i = i + 1
         end
      end
   end)
end

function Column:eval()
   if self.gen ~= nil and self:memo() == true then
        -- Drain the column
    local index = self:last_chunk() or 0 
    while self:materialized() == false do
        self:chunk(index)
        index = index + 1
    end
   end
end

function Column:persist(name)
 
    return string.format("Column{field_type='%s', filename='%s', nn=%s,}",self.vec.field_type, plpath.abspath(self.vec.filename), tostring(self.nn_vec ~=nil) )
end

function Column:__tostring()
 return string.format("Column{field_type='%s', filename='%s', nn=%s,}",self.vec.field_type, plpath.abspath(self.vec.filename), tostring(self.nn_vec ~=nil) )
end
return Column
