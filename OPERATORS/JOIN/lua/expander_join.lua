local ffi     = require 'ffi'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qc      = require 'Q/UTILS/lua/qcore'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function expander_unique(
  op, src_val, src_lnk, dst_lnk, join_types, optargs)
  -- Verification
  assert(op == "join")
  if ( not join_types ) then
    join_types = { "val" } -- default
  end
  assert(type(join_types) == "table")

  local sp_fn_name = "Q/OPERATORS/JOIN/lua/join_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs = pcall(spfn, 
  src_val, src_lnk, dst_lnk, join_types, optargs)
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  qc.q_add(subs)
  assert(qc[func_name], "Symbol not defined " .. func_name)

  -- TODO P1 Check that src_lnk and dst_lnk are sorted ascending 
  
  -- track how much of input you have consumed 
  local in_idx = ffi.new("uint32_t[?]", 1)
  -- how much of input buffer has been filled up
  local num_val_buf = ffi.new("uint32_t[?]", 1)
  num_val_buf[0] = 0
  -- whether val_buf will overflow if we consume more input
  local overflow = ffi.new("bool[?]", 1)
  overflow[0] = false

  local l_chunk_num = 0
  local in_chunk_num = 0 -- needed because consumption of input and 
   -- production of output do not go chunk by chunk 

  local in_len = 0; local in_buf = nil -- declare outside generator
  -- this is tricky part where we create 2 generators
  local vectors = {}
  local lgens = {}
  for _, my_join_type in ipairs(join_types) do 
    local function gen(chunk_num)
      assert(chunk_num == l_chunk_num)
      local dv_buf = cmem.new(subs.src_val_bufsz)
      dv_buf:zero()
      dv_buf:stealable(true)
  
      local nn_dv_buf = cmem.new(subs.nn_src_val_bufsz)
      nn_dv_buf:zero()
      nn_dv_buf:stealable(true)
  
      num_val_buf[0] = 0
  
      while ( true ) do 
        -- If first time OR you have consumed entire input chnk, get more
        if ( not in_buf ) then
          in_idx[0] = 0
          sv_len, sv_buf = src_val:get_chunk(in_chunk_num)
          sl_len, sl_buf = src_lnk:get_chunk(in_chunk_num)
          -- print("Getting chunk " .. in_chunk_num)
        else
          if ( in_len == in_idx[0] ) then 
            sv_buf:unget_chunk(in_chunk_num)
            sv_buf:unget_chunk(in_chunk_num)
            -- print("Ungetting input chunk " .. in_chunk_num)
            if ( in_len < sv_buf:max_num_in_chunk() ) then
              in_len = 0 -- indicating end of input
            else
              in_chunk_num = in_chunk_num + 1 
              sv_len, sv_buf = src_val:get_chunk(in_chunk_num)
              sl_len, sl_buf = src_lnk:get_chunk(in_chunk_num)
              in_idx[0] = 0
              -- print("Getting chunk " .. in_chunk_num)
            end
          else 
            print("Need to finish consuming input in chunk", in_chunk_num)
          end
        end
        --=== START handle case where no more input 
        if in_len == 0 then
          if ( num_val_buf[0] == 0 ) then 
            dv_buf:delete()
            nn_dv_buf:delete()
          end
          for _, join_type in ipairs(join_types) do 
            if ( join_type ~= my_join_type ) then
              -- TODO vectors.cnt:put_chunk(cnt_buf, num_val_buf[0])
              -- TODO vectors.cnt:eov()
            end
            -- TODO return num_val_buf[0], val_buf
          end
        end
        --=== STOP handle case where no more input 
        --======================================================
        local sv_ptr  = ffi.cast(subs.cast_sv_as,  get_ptr(sv_buf))
        local sl_ptr  = ffi.cast(subs.cast_sl_as,  get_ptr(sl_buf))
        -- local dv_ptr  = ffi.cast(subs.cast_sv_as,  get_ptr(dv_buf))
        -- local dv_ptr  = ffi.cast("bool *", get_ptr(nn_dv_buf))
        -- local dl_ptr  = ffi.cast(subs.cast_sl_as,  get_ptr(dl_buf))
  
        local status = qc[func_name](
          sv_ptr, sl_ptr, dl_ptr, dv_ptr, nn_dv_ptr, 
          in_ptr, in_len, val_ptr, cnt_ptr, 
          in_idx, num_val_buf, subs.max_num_in_chunk, overflow)
        if ( ( a:is_eov() ) and ( overflow[0] == true ) ) then
          a:unget_chunk(in_chunk_num)
          -- print("X: Ungetting input chunk " .. in_chunk_num)
        end

        -- print("Return from C code, overflow = ", overflow[0]);
        -- print("Return from C code, in_idx = ", in_idx[0]);
        assert(status == 0, "C error in UNIQUE")
        -- If output buffer is (truly) full then return it 
        if ( overflow[0] == true ) then 
          for _, join_type in ipairs(join_types) do 
            if ( join_type ~= my_join_type ) then
              -- TODO vectors.cnt:put_chunk(cnt_buf, num_val_buf[0])
            end
            -- TODO return num_val_buf[0], val_buf
          end
        end 
        --===================================================
      end -- end of while 
    end
    lgens[my_join_type] = gen
  end
  local val_args = {}
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
return expander_unique
