function KeyCounter:map_out(hidx, fld)
  assert(type(hidx) == "lVector")
  assert((hidx:qtype() == "I4" ) or (hidx:qtype() == "UI4" ))
  assert(type(fld) == "string")
  assert(self._is_eor) -- counter must be stable
  local bufsz = qcfg.max_num_in_chunk 
  local val_from_aux = true -- value to be mapped out in self._auxvals
  if ( ( fld == "count" ) or ( fld == "guid" ) or ( fld == "idx" ) ) then
    val_from_aux = false
  end
  local from_qtype
  local from_buf
  local from_ptr = ffi.NULL
  if ( val_from_aux ) then
    from_buf = assert(self._auxvals[fld])
    assert(type(from_buf == "CMEM"))
    from_qtype = assert(from_buf:qtype())
    from_ptr = get_ptr(from_buf, from_qtype)
  else
    from_qtype = "UI4" -- NOTE: Both guid and count are uint32_t
  end
  local from_width = cutils.get_width_qtype(from_qtype)
  assert(from_width > 0)

  -- ?? local get_idx_name = self._label .. "_rsx_kc_get_idx"
  -- ?? local get_idx_fn = assert(self._kc[get_idx_name])
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
    local out_buf = cmem.new(bufsz * buf_width)
    out_buf:stealable(true)
    local out_ptr = get_ptr(out_buf, buf_qtype)
    local hidx_ptr = get_ptr(hidx_chunk, "UI4")
    local status = map_out_fn(self._H, from_ptr, hidx_ptr, len, out_ptr)
    assert(status == 0)
    hidx:unget_chunk(chunk_num)
    l_chunk_num = l_chunk_num + 1 
    return len, out_buf
  end
  local vargs = {}
  local vargs = {gen = gen, qtype = out_qtype, has_nulls=false}
  return lVector(vargs)
end
