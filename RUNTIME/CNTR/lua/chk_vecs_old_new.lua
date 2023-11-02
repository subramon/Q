local function chk_vecs_old_new(vnew, vold)
  assert(type(vnew) == "table")
  -- START: vecs must match with vecs used to create KeyCounter
  assert(#vnew == #vold)
  for k, v in ipairs(vnew) do 
    assert(v:qtype() == vold[k]:qtype())
    assert(v:width() == vold[k]:width())
  end
  -- all incoming vectors should have same chunk size 
  for k, v in ipairs(vnew) do 
    assert(v:max_num_in_chunk() == vold[k]:max_num_in_chunk())
  end
  return true
end
return chk_vecs_old_new
