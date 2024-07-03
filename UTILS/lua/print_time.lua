local function print_time(
  )
  local x = _G['g_time']
  local y = _G['g_ctr']
  if ( x and y ) then 
    assert(type(x) == "table")
    assert(type(y) == "table")
    for k, v in pairs(x) do 
      print(k, x[k], y[k])
    end
  end
end
return print_time
