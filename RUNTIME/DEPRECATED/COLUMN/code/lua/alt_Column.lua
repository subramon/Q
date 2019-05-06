local log    = require 'Q/UTILS/lua/log'
local plpath = require("pl.path")
local qc     = require 'Q/UTILS/lua/q_core'
local clone  = require 'Q/UTILS/lua/utils'.clone
local ffi = require 'Q/UTILS/lua/q_ffi'
local Vector = require "Q/RUNTIME/COLUMN/code/lua/Vector"

local Column = {}
Column.__index = Column

setmetatable(Column, {
        __call = function (cls, ...)
            return cls.new(...)
        end,
    })

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
    -- column.destructor_ptr = ffi.malloc(1, column.destructor) -- Destructor hack for luajit
    -- DestructorLookup[column.destructor_ptr] = column
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
        return false
    else
        return true
    end
end

function Column:sz()
  return self.vec:sz()
end

function Column:memo(to_memo)
  -- if you memo a Column, both vec and nn_vec must be treated similarly
  self.vec:memo(to_memo)
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
        assert(self.vec ~= self.nn_vec, "The vectors are different")
    end
    return vec_num
end

function Column:materialized()
    return self.vec:materialized()
end

-- Do not use this interface. Higly discouraged and to be used for testing only
function Column:get_element(num)
    assert(num == math.floor(num), "element number needs to be a integer")
    assert(num >= 0, "Requires a whole number " .. tostring(num))
    local column_chunk_size = self.vec.chunk_size
    local size, chunk , nn_chunk = self:chunk(math.floor(num / column_chunk_size))
    local vec_val , nn_vec_val = nil, nil
    local offset = num % column_chunk_size
    assert(offset >= 0 and offset < column_chunk_size, "Element needs to be in current chunk")
    if size == nil or size == 0 then return 0 end
    chunk = ffi.cast("unsigned char*", chunk)
    if self.vec:fldtype() == "B1" then
        local char_offset = offset / 8
        local bit_offset = offset % 8
        local char_value = chunk + char_offset
        local bit_value = tonumber( qc.get_bit(char_value, bit_offset) )
        if bit_value == 0 then
           vec_val = ffi.NULL
        else
           vec_val =  1
        end
   else
      vec_val =  ffi.cast("void *", chunk +  offset * self.vec.field_size)
   end

   if self.nn_vec ~= nil then
        local char_offset = offset / 8
        local bit_offset = offset % 8
        local char_value = chunk + char_offset
        local bit_value = tonumber( qc.get_bit(char_value, bit_offset) )
        if bit_value == 0 then
           nn_vec_val = ffi.NULL
        else
           nn_vec_val =  1
        end
    end

    return vec_val, nn_vec_val
end

function Column:chunk(num)
    if num < 0 then 
        local chunk , size = self.vec:chunk(num)
        local nn_chunk, nn_size
        if self.nn_vec ~= nil then 
            nn_chunk, nn_size = self.nn_vec:chunk(-1)
            assert(nn_size == size, "Size of null vector and vector should be the same")
        end
        return size, chunk, nn_chunk
    end

    local chunk_num = self.vec:last_chunk()
    assert(type(num) == "number", "Require a number for chunk number")
    if self:materialized() == false and self.gen ~= nil and (chunk_num == nil or num == chunk_num + 1 ) then
        -- now the column has a generator to manage
        local status, size, vec_chunk, nn_vec_chunk = coroutine.resume(self.gen)
        if status  and size ~= nil then
            self.vec:put_chunk(vec_chunk, size)
            if self.nn_vec ~= nil then
                self.nn_vec:put_chunk(nn_vec_chunk, size)
                -- TODO Assert for else is removed for perf
            end
        else -- Basically means that the vector is exhausted
            if size ~= nil then
                log.fatal(size)
            end
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
      return 0, nil, nil
        -- assert(nil, "Bad index: " .. tostring(num))
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

function Column:eval()
    if self.gen ~= nil and self:ismemo() ~= false  then
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

return require('Q/q_export').export('Column', Column)
