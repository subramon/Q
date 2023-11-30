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
  local in_chunk_num = 0
  local in_idx = ffi.new("uint32_t[?]", 1)
  in_idx[0] = 0 
  -- Above means that we have consumed 0 elements out of 0 chunks 

  -- sv = source value
  -- sl = source link
  -- dv = destination value
  -- dl = destination link

  local l_chunk_num = 0
  -- this is tricky part where we create multiple generators,
  -- one for each join_type requested
  local vectors = {}
  local lgens = {}
  for _, my_join_type in ipairs(join_types) do 
    local function gen(chunk_num)
      assert(chunk_num == l_chunk_num)
      -- allocate buffers for output 
      local dv_bufs = {}; local nn_dv_bufs = {}
      for _, join_type in ipairs(join_types) do
        local dv_buf = cmem.new(subs.src_val_bufsz)
        dv_buf:zero()
        dv_buf:stealable(true)
  
        local nn_dv_buf = cmem.new(subs.nn_src_val_bufsz)
        nn_dv_buf:zero()
        nn_dv_buf:stealable(true)

        dv_bufs[join_type]    = dv_buf
        nn_dv_bufs[join_type] = nn_dv_buf
      end
      --==========================================================
      dl_len, dl_buf = dst_lnk:get_chunk(l_chunk_num)
      if ( dl_len == 0 ) then
        if ( YYY ) then 
          sv_buf:unget_chunk(in_chunk_num)
          sl_buf:unget_chunk(in_chunk_num)
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
      while ( true ) do 
        -- If first time OR you have consumed entire input chnk, get more
        if ( XXXX ) then 
          sv_buf:unget_chunk(in_chunk_num)
          sl_buf:unget_chunk(in_chunk_num)
          in_chunk_num = in_chunk_num + 1 
          sv_len, sv_buf = src_val:get_chunk(in_chunk_num)
          sl_len, sl_buf = src_lnk:get_chunk(in_chunk_num)
          assert(sl_len = sv_len)
          if ( sv_buf ) then assert(sl_buf) end 
          if ( not sv_buf ) then assert(not sl_buf) end 
          in_idx[0] = 0
          -- print("Getting chunk " .. in_chunk_num)
        end 
      end
      -- get pointers to sl, sv, dl
      local sv_ptr  = ffi.cast(subs.cast_sv_as, get_ptr(sv_buf))
      local sl_ptr  = ffi.cast(subs.cast_sl_as, get_ptr(sl_buf))
      local dl_ptr  = ffi.cast(subs.cast_dl_as, get_ptr(dl_buf))
        --======================================================
      -- with the same values of sl, sv, dl we perform many different joins
      for k, join_type in ipairs(join_types) do
        local dv_ptr  = ffi.cast(subs.cast_sv_as, get_ptr(dv_bufs[join_type]))
        local nn_dv_ptr  = ffi.cast("bool *", get_ptr(nn_dv_bufs[join_type))
        local func_name = subs.fns[k]
        local status = qc[func_name](
          sv_ptr, sl_ptr, dl_ptr, dv_ptr, nn_dv_ptr, 
          sl_len, dl_len, XXXX)
          assert(status == 0)
      end
      for _, join_type in ipairs(join_types) do 
        if ( join_type ~= my_join_type ) then
          vectors[join_type]:put_chunk(
            dv_bufs[join_type], dl_len, 
            nn_dv_bufs[join_type])
        end 
      end
      return dl_len, dv_bufs[my_join_type], nn_dv_bufs[my_join_type]
        --===================================================
    end
    lgens[my_join_type] = gen
  end
  local dst_val_args = {}
  val_args.qtype = subs.val_qtype
  val_args.max_num_in_chunk = subs.max_num_in_chunk
  val_args.has_nulls = false
  val_args.gen = lgens["val"]
  vectors.val = lVector(val_args)

  local cnt_args = {}
  cnt_args.qtype = subs.cnt_qtype
  cnt_args.max_num_in_chunk = subs.max_num_in_chunk
  cnt_args.has_nulls = false
  cnt_args.gen = lgens["cnt"]
  vectors.cnt = lVector(cnt_args)

  return vectors.val, vectors.cnt
end
return expanderjoin
