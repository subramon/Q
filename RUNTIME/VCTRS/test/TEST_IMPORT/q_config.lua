local T = {}

T.restore_session = false

T.is_webserver     = false
T.web_port         = 8004

T.is_out_of_band   = false
T.out_of_band_port = 8008

T.is_mem_mgr       = false

local x = assert(os.getenv("Q_SRC_ROOT"))
x = x .. "/RUNTIME/VCTRS/test/TEST_IMPORT/"

T.meta_dir_root = x .. "meta"
T.data_dir_root = x .. "data"

T.mem_allowed = 4   -- in GBytes
T.dsk_allowed = 16  -- in GBytes
T.vctr_hmap = { 
  min_size = 32,
  max_size = 0
}
T.chnk_hmap = { 
  min_size = 32,
  max_size = 0
}

T.initial_master_interested = true 
return T
