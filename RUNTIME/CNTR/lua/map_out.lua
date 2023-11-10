function KeyCounter:map_out(hidx, fld)
  assert(type(hidx) == "lVector")
  assert((hidx:qtype() == "I4" ) or (hidx:qtype() == "UI4" ))
  assert(type(fld) == "string")
  assert(self._is_eor) -- counter must be stable
  local bufsz = qcfg.max_num_in_chunk 
  local from_qtype
  local from_buf
  local from_ptr = ffi.NULL
  --=====================================
  -- Figure out where you are going to get data from 
  local val_from_aux = true -- value to be mapped out in self._auxvals
  if ( fld == "count" ) or ( fld == "guid" ) then
    val_from_aux = false
    from_qtype = "UI4" -- NOTE: Both guid and count are uint32_t
  else
    from_buf = assert(self._auxvals[fld])
    assert(type(from_buf == "CMEM"))
    from_qtype = assert(from_buf:qtype())
    from_ptr = get_ptr(from_buf, from_qtype)
  else
  end
  local from_width = cutils.get_width_qtype(from_qtype)
  assert(from_width > 0)
  local to_qtype = from_qytpe
  local to_width = from_qytpe
  --=====================================

  local map_out_name = self._label .. "_rsx_kc_map_out"
  local map_out_fn = assert(self._kc[map_out_name])
  local l_chunk_num = 0
  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    local len, hidx_chunk = hidx:get_chunk(chunk_num)
    --================================================
    if ( len == 0 ) then 
      print("D: No more chunks", self._chunk_num)
      return 0
    end
    --================================================
    local to_buf = cmem.new(bufsz * to_width)
    to_buf:stealable(true)
    local to_ptr = get_ptr(to_buf, buf_qtype)
    local hidx_ptr = get_ptr(hidx_chunk, "UI4")
    local status = map_out_fn(self._H, from_ptr, hidx_ptr, len, to_ptr)
    assert(status == 0)
    hidx:unget_chunk(chunk_num)
    l_chunk_num = l_chunk_num + 1 
    return len, to_buf
  end
  local vargs = {}
  local vargs = {gen = gen, qtype = out_qtype, has_nulls=false}
  return lVector(vargs)
end
