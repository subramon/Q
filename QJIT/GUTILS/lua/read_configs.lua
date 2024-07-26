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

  bool initial_master_interested;
} q_config_t;
]])
local function read_configs(C)
  assert(type(T) == "table") 
  -- T is a global table containing config info 
  assert(type(T.restore_session) == "boolean")

  --===============================================
  if (type(T.is_webserver)   == "nil") then 
    T.is_webserver = false
  end 
  assert(type(T.is_webserver)   == "boolean")
  --===============================================
  if (type(T.is_out_of_band) == "nil") then
    T.is_out_of_band = false
  end
  assert(type(T.is_out_of_band) == "boolean")
  --===============================================

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

  if ( type(T.initial_master_interested) == "nil" ) then 
    T.initial_master_interested = true
  end
  assert(type(T.initial_master_interested) == "boolean" )

  assert(type(T.mem_allowed) == "number")
  assert(T.mem_allowed > 0)

  --[[ THIS DOES NOT WORK BECAUSE -e args not passed through 
  --to the new Lua state in which this is executed 
  -- You can over-ride configs from command line by doing
  -- lua foo.lua -e "over_rides = { mem_allowed = 2, dsk_allowed = 3}"
    print("YYYYYYYYYYYYYYYY")
  if (over_rides ) then  
    print("XXXXXXXXXXXXXXXX")
    assert(type(over_rides) == "true")
    for k1, v1 in pairs(over_rides) do
      assert(type(k1) == "string")
      found = false;
      for k2, v2 in pairs(T) do 
        if ( k1 == k2 ) then
          print("over ride " .. k .. " from " .. T.k1 .. " to " .. v1)
          T.k1 = v1
          found = true
          break
        end
      end
      if ( not found ) then
        error("Invalid over-ride of " .. k2) 
      end
    end
  end
  --]]

  --=== Put it into C struct 
  C = ffi.cast("q_config_t *", C)
  C[0].restore_session = T.restore_session
  -----------------------
  C[0].is_webserver   = T.is_webserver
  C[0].is_out_of_band = T.is_out_of_band
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

  C[0].initial_master_interested = T.initial_master_interested
  return true
end
return read_configs
