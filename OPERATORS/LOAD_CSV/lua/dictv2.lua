_G["Q_DICTIONARIES"] = _G['Q_DICTIONARIES'] or {}

local dict_obj_mt = {
    __newindex = function(self, key, value)
        print("newindex metamethod called")
        assert(value == true, "Dictionary only accepts setting values")
        if self.add == false then error("Cannot add to this dictionary", 2) end
        if type(key) == "string" then
            local index = self.string_to_index[key]
            if index == nil then
                index = #self.index_to_string + 1
                self.index_to_string[index] = key
                self.string_to_index[key] = index
            end
            return index
        else
            error("adding to dictionary requires string", 2)
        end
        return nil
    end,
    __index = function(self, key)
        -- Called only when the string we want to use is an
        -- entry in the table, so our variable names
        print("index metamethod called")
        if type(key) == "string" then
            return self.string_to_index[key]
        elseif type(key) == "number" then
            return self.index_to_string[key]
        else
            error("only string or numbers are permitted", 2)
        end
        return nil
    end,
    __len = function(self)
        print("len metamethod called")
    return #self.index_to_string end,
}
dict_obj_mt.__add = function(lhs, rhs)
    if type(lhs) == "Dictionary" then 
        return dict_obj_mt.__newindex(lhs, rhs, true)
    elseif type(lhs) == "Dictionary" then
         return dict_obj_mt.__newindex(rhs, lhs, true)
    else
        error("Can only add a string to dictionary", 2)
    end
        return nil
end

local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
    local otype = original_type( obj )
    if  otype == "table" and getmetatable( obj ) == dict_obj_mt then
        return "Dictionary"
    end
    return otype
end

return function (dict_name, add)
    local dict = _G["Q_DICTIONARIES"][dict_name]
    if not dict then
        if add == nil then add = true end
        local n_dict = {}
        n_dict.add = add
        n_dict.string_to_index = {}
        n_dict.index_to_string = {}
        dict = setmetatable(n_dict, dict_obj_mt)
        _G["Q_DICTIONARIES"][dict_name] = dict
        -- Create a forward map and a reverse map
    end
    return dict
end
