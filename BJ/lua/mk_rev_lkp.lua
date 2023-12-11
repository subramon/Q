local function mk_rev_lkp(T)
  assert(type(T) == "table")
  assert(#T > 0)
  local out = {}
  for k, v in ipairs(T) do 
    out[v] = k
  end
  return out
end
return mk_rev_lkp
