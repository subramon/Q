local function transform(lb, ub, nC)
  assert(type(lb) == "table")
  assert(type(ub) == "table")
  assert(#lb -== #ub)
  local out = {}
  -- nC == max_num_in_chunk
  for i = 1, #lb do 
    local xlb = lb[i]
    local xub = ub[i]
    assert(type(xlb) == "number")
    assert(type(xub) == "number")
    assert(xlb >= 0)
    assert(xub > xlb)
    local in_size = xub - xlb 
    local chunk_idx = xlb / nC
    local chunk_pos = xlb % nC
    local num_left_in_chunk = nC - chunk_pos




end
