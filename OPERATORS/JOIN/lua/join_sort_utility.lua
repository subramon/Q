local qtils = require 'Q/QTILS/lua/is_sorted'
local sort = require 'Q/OPERATORS/SORT/lua/sort'
local sort2 = require "Q/OPERATORS/SORT2/lua/sort2"

local sort_vector = function(a, drag_along)
  local a_clone = a
  local drag_clone = drag_along
  -- NOTE: For join operator, input vector needs to be sorted(asc)
  local sort_order = a:get_meta("sort_order")
  -- if sort_order field is nil then check the input vector for sort order
  if ( sort_order == nil ) then
    -- calling an utility called is_sorted(vec)
    local status, order = qtils.is_sorted(a)
    -- if input vector is not sorted, cloning and sorting that cloned vector
    if status == false or order == "dsc" then
      if drag_along ~= nil then 
        a_clone = a:clone()
        drag_clone = drag_along:clone()
        print(a_clone:qtype())
        sort2(a_clone, drag_clone, "asc")
        print(a_clone:qtype())
      else
        a_clone = a:clone()
        sort(a_clone, "asc")
      end
    else
      assert( status == true, "is_sorted utility failed")
      assert( order, "input vector not sorted")
      print(a_clone:qtype())
      a_clone:set_meta( "sort_order", order)
    end
  end

  -- getting updated sort_order meta value if sort_order was nil
  sort_order = a_clone:get_meta( "sort_order" )
  assert( (sort_order == "asc"),
      "input vector not sorted")
  if drag_along ~= nil then
    return a_clone, drag_clone
  else
    return a_clone
  end
end

return sort_vector