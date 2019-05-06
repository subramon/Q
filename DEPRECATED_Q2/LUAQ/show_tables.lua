#!/home/subramon/lua-5.3.0/src/lua
function chk_show_tables(J)
  assert(type(J) == "table")
  return true
end
-- ===============================================================
function exec_show_tables (J)
  nT = 0
  _t = {}
  for k, v in pairs(T) do
    print(k);
    nT = nT + 1
    _t[nT] = k
  end
  if ( nT == 0 ) then _t[0] = "NO TABLES"; print ("No tables exist") end 
  return _t
end
-- ===============================================================
function update_show_tables(J)
  return true
end
-- ===============================================================
