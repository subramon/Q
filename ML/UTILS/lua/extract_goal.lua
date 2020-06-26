-- given a table T of lVectors and a string identifying the goal attribute
-- return
-- 1) a table t of lVectors = T - g, indexed as foo, bar,... 
-- 2) a goal lvector g
-- 3) a table t_names of strings, with names of Vectors
local function extract_goal(
  T, 
  goal
  )
  assert(type(T) == "table")
  assert(type(goal) == "string")
  local t = {}
  local t_names = {}
  local g 
  local qtype 
  local m = 0
  local n = 0
  for k, v in pairs(T) do 
    assert(type(v) == "lVector")
    assert(v:is_eov())
    if ( k == goal ) then 
      g = v
    else
      if ( not qtype ) then
        n = v:length()
      else
        assert(n     == v:length())
      end
      t[#t+1] = v
      t_names[#t_names+1] = k
      m = m + 1
    end
  end
  assert(m > 0)
  assert(n > 0)
  assert(g)
  assert(type(g) == "lVector")
  assert(type(t) == "table")
  return t, g, t_names
end
return extract_goal
