#!/home/subramon/lua-5.3.0/src/lua
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
  return nil; -- nothing to report to caller
end
