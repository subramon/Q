local plpath = require 'pl.path'
local function get_meta_file()
  local q_meta_dir = os.getenv("Q_METADATA_DIR")
  local q_meta_file = os.getenv("Q_METADATA_FILE")
  local meta_data_file
  if q_meta_file then
    meta_data_file = q_meta_file
  elseif q_meta_dir then
    assert(plpath.isdir(q_meta_dir))
    meta_data_file = q_meta_dir .. "/occupancy.saved"
  else
    meta_data_file = plpath.currentdir() .. "/occupancy.saved"
  end
  assert(type(meta_data_file) == "string")
  return meta_data_file
end
return get_meta_file
