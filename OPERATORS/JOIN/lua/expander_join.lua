local ffi     = require 'ffi'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qc      = require 'Q/UTILS/lua/qcore'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function expander_join(
  op, src_val, src_lnk, dst_lnk, join_types, optargs)
  -- Verification
  assert(op == "join")
  if ( not join_types ) then
    join_types = { "val" } -- default
  end
  assert(type(join_types) == "table")

  local sp_fn_name = "Q/OPERATORS/JOIN/lua/join_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, multi_subs = pcall(spfn, 
    src_val, src_lnk, dst_lnk, join_types, optargs)
  if not status then 
    print(multi_subs); error("Specializer failed " .. sp_fn_name)
  end
  for _, subs in pairs(multi_subs) do 
    local func_name = subs.fn 
    qc.q_add(subs)
    assert(qc[func_name], "Symbol not defined " .. func_name)
  end
  -- TODO P1 Check that src_lnk and dst_lnk are sorted ascending 
  
  -- track how much of input you have consumed 
  local src_chunk_num = 0
  local src_start = ffi.new("uint32_t[?]", 1)
  src_start[0] = 0 
  local dst_start = ffi.new("uint32_t[?]", 1)
  dst_start[0] = 0 
  -- Above means that we have consumed 0 elements out of 0 chunks 

  -- sv = source value
  -- sl = source link
  -- dv = destination value
  -- dl = destination link

  local l_chunk_num = 0
  -- this is tricky part where we create multiple generators,
  -- one for each join_type requested
  local vectors = {}
  local gens = {}
  for _, my_join_type in ipairs(join_types) do 
    local subs = multi_subs[my_join_type]
    local function gen(chunk_num)
      assert(chunk_num == l_chunk_num)
      -- allocate buffers for output 
      local dv_bufs = {}; local nn_dv_bufs = {}
      for _, join_type in ipairs(join_types) do
        local dv_buf = assert(cmem.new(subs.src_val_bufsz))
        dv_buf:zero()
        dv_buf:stealable(true)
  
        local nn_dv_buf = assert(cmem.new(subs.nn_dst_val_bufsz))
        nn_dv_buf:zero()
        nn_dv_buf:stealable(true)

        dv_bufs[join_type]    = dv_buf
        nn_dv_bufs[join_type] = nn_dv_buf
      end
      --==========================================================
      print("DST:   Getting " .. l_chunk_num)
      local dl_len, dl_buf = dst_lnk:get_chunk(l_chunk_num)
      dst_start[0] = 0
      print("dl_len = ", dl_len)
      if ( dl_len == 0 ) then
        if ( true ) then -- TODO P0 MAJOR HACK
          print("XXXXXX")
          sv_buf:unget_chunk(src_last_chunk_gotten)
          sl_buf:unget_chunk(src_last_chunk_gotten)
          src_last_chunk_gotten = -1
        end
        dv_buf:delete()
        nn_dv_buf:delete()
        for _, join_type in ipairs(join_types) do 
          if ( join_type ~= my_join_type ) then
            vectors[join_type]:eov() -- tell other vectors they are over 
          end
        end
        return 0  -- tell my vector that it is over 
      end
      -- Use sl, sv, dl to populate dv
      -- need a while loop becuase may need to consume > 1 chunk of sl/sv
      -- to produce one chunk of dv 
      local sv_len, sv_buf = src_val:get_chunk(src_chunk_num)
      local sl_len, sl_buf = src_lnk:get_chunk(src_chunk_num)
       print("SRC:   Getting " .. src_chunk_num)
      -- basic tests 
      assert(sl_len == sv_len)
      if ( sv_buf ) then assert(sl_buf) end 
      if ( not sv_buf ) then assert(not sl_buf) end 
        --================================================
      -- get pointers to sl, sv, dl
      local sv_ptr = ffi.NULL; local sl_ptr = ffi.NULL;
      if ( sl_len > 0 ) then 
        sl_ptr  = ffi.cast(subs.src_lnk_cast_as, get_ptr(sl_buf))
        sv_ptr  = ffi.cast(subs.src_val_cast_as, get_ptr(sv_buf))
      end
      local dl_ptr  = ffi.cast(subs.src_lnk_cast_as, get_ptr(dl_buf))
        --======================================================
      -- with the same values of sl, sv, dl we perform many different joins
      for k, join_type in ipairs(join_types) do
        local dv_ptr  = ffi.cast(subs.src_val_cast_as, 
          get_ptr(dv_bufs[join_type]))
        local nn_dv_ptr  = ffi.cast("bool *", 
          get_ptr(nn_dv_bufs[join_type]))
        local func_name = subs.fn
        local status = qc[func_name](
          sv_ptr, sl_ptr, src_start, sl_len, dl_ptr, dv_ptr, nn_dv_ptr, 
          dst_start, dl_len)
          assert(status == 0)
      end
      for _, join_type in ipairs(join_types) do 
        if ( join_type ~= my_join_type ) then
          vectors[join_type]:put_chunk(
            dv_bufs[join_type], dl_len, 
            nn_dv_bufs[join_type])
        end 
      end
      -- handle case when src buffer is over and you need to get new one
      if ( sl_len > 0 and src_start[0] == sl_len ) then 
        -- source buffer consumed 
        print("SRC: Ungetting " .. src_chunk_num)
        src_val:unget_chunk(src_chunk_num)
        src_lnk:unget_chunk(src_chunk_num)
        src_chunk_num = src_chunk_num + 1
        src_start[0] = 0
      end
      dst_lnk:unget_chunk(l_chunk_num)
      return dl_len, dv_bufs[my_join_type], nn_dv_bufs[my_join_type]
        --===================================================
    end
    gens[my_join_type] = gen
  end
  for _, join_type in ipairs(join_types) do 
    local subs = multi_subs[join_type]
    local vargs = {}
    vargs.has_nulls        = true
    vargs.gen              = gens[join_type]
    vargs.qtype            = subs.src_val_qtype
    vargs.max_num_in_chunk = subs.max_num_in_chunk

    vectors[join_type] = lVector(vargs)
  end
  return vectors
end
return expander_join
