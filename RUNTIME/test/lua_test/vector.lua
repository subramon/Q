local Vector = require 'libvec'
local qconsts = require 'Q/UTILS/lua/q_consts'
local q_data_dir = os.getenv("Q_DATA_DIR")
q_data_dir = q_data_dir .. "/"
-- input args are in the order below
-- M - metadata containing qtype, file_name, is_read_only, is_memo, num_elements depending on vector type (nascent / materialized)
return function( M )
  assert(M.qtype, "qtype is not provided")
  
  local field_size = qconsts.qtypes[M.qtype].width
  
  -- Check for SC type
  if M.qtype == "SC" then
    assert(M.width, "Field size is not provided for SC")
    assert(type(M.width) == "number", "Provided field_size is not number")
    M.qtype = "SC:" .. M.width
    field_size = M.width
  end
  
  -- Create Vector
  local status, x = pcall(Vector.new, M.qtype, qconsts.Q_DATA_DIR, M.file_name, M.is_memo, M.num_elements)
  if not status then
    print(x)
    x = nil
  end
  return x
end
