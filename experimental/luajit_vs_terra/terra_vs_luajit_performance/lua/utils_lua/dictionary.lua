-- START: Following is standard stuff for creating a class 
local Dictionary = {}
local g_err = require("error_code")
_G["Q_DICTIONARIES"] = _G["Q_DICTIONARIES"] or {}
Dictionary.__index = Dictionary

setmetatable(Dictionary, {
        __call = function (cls, ...)
            return cls.get_instance(...)
        end,
    })

local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
    local otype = original_type( obj )
    if  otype == "table" and getmetatable( obj ) == Dictionary then
        return "Dictionary"
    end
    return otype
end
-- STOP: Following is standard stuff for creating a class 

function Dictionary.get_instance(
  dict_name
  )
    local dict = _G["Q_DICTIONARIES"][dict_name]
    if not dict then
        dict = setmetatable({}, Dictionary)
        _G["Q_DICTIONARIES"][dict_name] = dict
        -- Create a forward map and a reverse map
        dict.string_to_index = {}
        dict.index_to_string = {}
        dict.name = dict_name
    end
    return dict
end

function Dictionary:get_string_by_index(index)
    return self.index_to_string[index]
end

function Dictionary:get_index_by_string(text)
    return self.string_to_index[text]
end

function Dictionary:add(text)
    assert(text and text ~= "", g_err.ADD_NIL_EMPTY_ERROR_IN_DICT )
    local index = self:get_index_by_string(text)
    if not index then
        index = #self.index_to_string + 1
        self.string_to_index[text] = index
        self.index_to_string[index] = text
    end
    return index
end

function Dictionary:get_size()
    return #self.index_to_string
end

function Dictionary:persist(var_name)
    ret_table= {}
    ret_table[#ret_table + 1] = string.format('Dictionary{"%s"}', self.name)
    for k,v in ipairs(self.index_to_string) do
        ret_table[#ret_table + 1] = string.format("%s.add('%s')", var_name, v)
    end
    return table.concat(ret_table, "\n")
end

return Dictionary
