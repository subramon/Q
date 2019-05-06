#!/home/subramon/LUA/lua-5.3.0/src/lua
function qinit()
  dofile "../LUAQ/metaq.lua"
  dofile "../LUAQ/q.lua"
  dofile "../LUAQ/aux.lua"
  
  dofile "../LUAQ/add_tbl.lua"
  dofile "../LUAQ/add_fld.lua"
  dofile "../LUAQ/del_tbl.lua"
  dofile "../LUAQ/del_fld.lua"
  dofile "../LUAQ/tbl_meta.lua"
  dofile "../LUAQ/show_tables.lua"
  dofile "../LUAQ/fld_meta.lua"
  dofile "../LUAQ/s_to_f.lua"
  dofile "../LUAQ/f_to_s.lua"
  dofile "../LUAQ/set_meta.lua"

  dofile "../LUAQ/chk_f1opf2.lua"
  
  json = (loadfile "../../../LUA/json.lua")() -- TOOD: FIX
  fn,err = package.loadlib('/tmp/qglue.so','luaopen_qglue')
  if not fn then 
    print(err)
  else
    fn()
  end
  
  assert(io.input("../LUAQ/f_to_s_IO.json"))
  local x = assert(io.read("*all"))
  f_to_s_IO = json:decode(x)

  assert(io.input("../LUAQ/add_fld_IO.json"))
  local x = assert(io.read("*all"))
  add_fld_IO = json:decode(x)

  assert(io.input("../LUAQ/s_to_f_IO.json"))
  local x = assert(io.read("*all"))
  s_to_f_IO = json:decode(x)

  assert(io.input("../LUAQ/f1opf2_IO.json"))
  local x = assert(io.read("*all"))
  f1opf2_IO = json:decode(x)

-- TODO: Do we need to close input file?
  assert(io.input("../LUAQ/fldsz.json"))
  local x = assert(io.read("*all"))
  T_fldsz = json:decode(x)

  assert(io.input("../LUAQ/fld_meta_IO.json"))
  local x = assert(io.read("*all"))
  T_fld_meta = json:decode(x)

end
