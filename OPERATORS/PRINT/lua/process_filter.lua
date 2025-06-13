local function process_filter(filter, vec_length)
  local lb, ub, where
  if filter then
    assert(type(filter) == "table")
    lb    = filter.lb
    ub    = filter.ub
    where = filter.where
    if ( where ) then
      assert(type(where) == "lVector")
      assert(where:qtype() == "BL") -- TODO P0 Was B1 will BL work?
      assert(not where:has_nulls())
    end
    if ( lb ) then
      assert(type(lb) == "number")
      assert(lb >= 0)
    else
      lb = 0;
    end
    if ( ub ) then
      assert(type(ub) == "number")
      assert(ub > lb)
      assert(ub <= vec_length)
    else
      ub = vec_length
    end
  else
    lb = 0
    ub = vec_length
  end
  return lb, ub, where
end
return process_filter
