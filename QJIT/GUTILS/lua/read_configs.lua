local ffi = require 'ffi'
ffi.cdef(' extern void *malloc(size_t size);')
local function stringify(str)
  assert(type(str) == "string")
  assert(#str >= 0) -- note that empty strings are allowed
  local len = #str + 1
  local cstr = assert(ffi.C.malloc(len))
  ffi.fill(cstr, len)
  ffi.copy(cstr, str, len-1)
  return ffi.cast("char *", cstr)
end

ffi.cdef([[
typedef struct  _q_config_t {
  bool restore_session;
  //-----------------------
  bool is_webserver;
  bool is_out_of_band;
  bool is_mem_mgr;
  //-----------------------
  char *data_dir_root;
  char *meta_dir_root;

  uint64_t mem_allowed;
  uint64_t dsk_allowed;

  int web_port;
  int out_of_band_port;

  uint32_t vctr_hmap_min_size;
  uint32_t vctr_hmap_max_size;

  uint32_t chnk_hmap_min_size;
  uint32_t chnk_hmap_max_size;
} q_config_t;
]])
local function read_configs(C)
  assert(type(T) == "table") 
  -- T is a global table containing config info 
  assert(type(T.restore_session) == "boolean")

  assert(type(T.is_webserver)   == "boolean")
  assert(type(T.is_out_of_band) == "boolean")
  assert(type(T.is_mem_mgr)     == "boolean")

  assert(type(T.data_dir_root) == "string")
  assert(type(T.meta_dir_root) == "string")
  -- TODO P3 Verify that these directories exist

  assert(type(T.mem_allowed) == "number")
  assert(T.mem_allowed > 0)

  assert(type(T.dsk_allowed) == "number")
  assert(T.dsk_allowed > 0)

  if ( T.is_webserver ) then
    assert(type(T.web_port) == "number")
    assert(T.web_port > 0)
  else 
    T.web_port = 0
  end
  if ( T.is_out_of_band ) then
    assert(type(T.out_of_band_port) == "number")
    assert(T.out_of_band_port > 0)
  else
    T.out_of_band_port  = 0
  end
  if ( T.is_webserver ) and ( T.is_out_of_band ) then
    assert(type(T.web_port) ~= T.mem_mgr_port)
  end

  local vctr = assert(T.vctr_hmap)
  assert(type(vctr) == "table")
  assert(vctr.min_size > 0)
  if ( vctr.max_size > 0 ) then 
    assert(type(vctr.min_size) < vctr.max_size)
  else
    vctr.max_size = 0
  end

  local chnk = assert(T.chnk_hmap)
  assert(type(chnk) == "table")
  assert(chnk.min_size > 0)
  if ( chnk.max_size > 0 ) then 
    assert(type(chnk.min_size) < chnk.max_size)
  else
    chnk.max_size = 0
  end
  --=== Put it into C struct 
  C = ffi.cast("q_config_t *", C)
  C[0].restore_session = T.restore_session
  -----------------------
  C[0].is_webserver   = T.is_webserver
  C[0].is_out_of_band = T.is_out_of_band
  C[0].is_mem_mgr     = T.is_mem_mgr
  -----------------------
  C[0].data_dir_root = stringify(T.data_dir_root)
  C[0].meta_dir_root = stringify(T.meta_dir_root)

  C[0].mem_allowed = T.mem_allowed
  C[0].dsk_allowed = T.dsk_allowed

  C[0].web_port         = T.web_port
  C[0].out_of_band_port = T.out_of_band_port

  C[0].vctr_hmap_min_size = vctr.min_size
  C[0].vctr_hmap_max_size = vctr.max_size

  C[0].chnk_hmap_min_size = chnk.min_size
  C[0].chnk_hmap_max_size = chnk.max_size

  return true
end
return read_configs
