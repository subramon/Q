-- given a table T of lVectors and a string identifying the goal attribute
-- return
-- 1) a goal lvector g
-- 2) a table t of lVectors = T - g
-- 3) m = number of columns of t 
-- 4) n = length of lVectors
local function extract_goal(
  T, 
  goal
  )
  assert(type(T) == "table")
  assert(type(goal) == "string")
  local t = {}
  local t_name = {}
  local g = nil
  local qtype = nil
  local m = 0
  local n = 0
  for k, v in pairs(T) do 
    assert(type(v) == "lVector")
    if ( k == goal ) then 
      g = v
    else
      if ( not qtype ) then
        qtype = v:fldtype()
        assert((qtype == "F4" ) or ( qtype == "F8"))
        n = v:length()
      else
        assert(qtype == v:fldtype())
        assert(n     == v:length())
      end
      t[#t+1] = v
      t_name[#t_name+1] = k
      m = m + 1
    end
  end
  assert(m > 0)
  assert(n > 0)
  assert(g)
  assert(qtype)
  assert(type(g) == "lVector")
  assert(type(t) == "table")
  return t, g, m, n, t_name
end
return extract_goal
