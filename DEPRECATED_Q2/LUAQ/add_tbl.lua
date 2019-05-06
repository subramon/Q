#!/home/subramon/lua-5.3.0/src/lua
function chk_add_tbl(J)
  assert(J ~= nil)
  assert(type(J) == "table")
  local x_t  = assert(J.tbl)
  assert(chk_tbl_name(x_t))
  local args = assert(J.ARGS)
  assert(type(args) == "table")
  local NumRows = assert(tonumber(args.NumRows))
  assert(math.floor(NumRows) == NumRows)
  assert(NumRows > 0)
  return true
end
--========================================================
function exec_add_tbl (J)
  local tbl  = assert(J.tbl)
  -- delete table if it exists
  local t = T[tbl]
  if ( t ~= nil ) then 
    exec_del_tbl(J) 
    update_del_tbl(J) 
  end
  -- create table
  assert(tostring(DOCROOT), "DOCROOT not specified")
  newdir = DOCROOT .. "/" .. tbl
  assert(g_lfs.mkdir(newdir), "Unable to mkdir " .. newdir)
  return true
end
--========================================================
function update_add_tbl (J)
  local tbl     = assert(J.tbl)
  local args = assert(J.ARGS)
  local NumRows = assert(tonumber(args.NumRows))
  -- STOP: Error checking
  _t = {}
  _props = {}
  _props.NumRows = NumRows
  _props.Exists  = true
  _props.RefCount  = 0
  _t.Properties = _props
  T[tbl] = _t;
  return true
end
