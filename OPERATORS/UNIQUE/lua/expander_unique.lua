local ffi     = require 'ffi'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qc      = require 'Q/UTILS/lua/qcore'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
-- TODO local sort_utility = require 'Q/OPERATORS/UNIQUE/lua/unique_sort_utility'

local function expander_unique(op, a)
  -- Verification
  assert(op == "unique")
  assert(type(a) == "lVector", "a must be a lVector ")
  local sp_fn_name = "Q/OPERATORS/UNIQUE/lua/unique_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs = pcall(spfn, a)
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  qc.q_add(subs)
  assert(qc[func_name], "Symbol not defined " .. func_name)

  -- TODO P1 Check that a is sorted. a = sort_utility(a)
  
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
  for _, my_name in ipairs({"val", "cnt"}) do 

    local function gen(chunk_num)
      assert(chunk_num == l_chunk_num)
      local val_buf = cmem.new(subs.val_bufsz)
      val_buf:zero()
      val_buf:stealable(true)
  
      local cnt_buf = cmem.new(subs.cnt_bufsz)
      cnt_buf:zero()
      cnt_buf:stealable(true)

      num_val_buf[0] = 0
  
      while ( true ) do 
        -- If first time OR you have consumed entire input chnk, get more
        if ( not in_buf ) then
          in_idx[0] = 0
          in_len, in_buf = a:get_chunk(in_chunk_num)
          -- print("Getting chunk " .. in_chunk_num)
        else
          if ( in_len == in_idx[0] ) then 
            a:unget_chunk(in_chunk_num)
            -- print("Ungetting input chunk " .. in_chunk_num)
            if ( in_len < a:max_num_in_chunk() ) then
              in_len = 0 -- indicating end of input
            else
              in_chunk_num = in_chunk_num + 1 
              in_len, in_buf = a:get_chunk(in_chunk_num)
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
            val_buf:delete()
            cnt_buf:delete()
          end
          if ( my_name == "val" ) then 
            vectors.cnt:put_chunk(cnt_buf, num_val_buf[0])
            vectors.cnt:eov()
          return num_val_buf[0], val_buf
          elseif ( my_name == "cnt" ) then 
            vectors.val:put_chunk(val_buf, num_val_buf[0])
            vectors.val:eov()
            return num_val_buf[0], cnt_buf
          else
            error("XXX")
          end
        end
        --=== STOP handle case where no more input 
        --======================================================
        local in_ptr  = ffi.cast(subs.val_ctype .. "*",  get_ptr(in_buf))
        local val_ptr = ffi.cast(subs.val_ctype .. "*",  get_ptr(val_buf))
        local cnt_ptr = ffi.cast(subs.cnt_ctype .. "*",  get_ptr(cnt_buf))
  
        local status = qc[func_name](in_ptr, in_len, val_ptr, cnt_ptr, 
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
          if ( my_name == "val" ) then 
            vectors.cnt:put_chunk(cnt_buf, num_val_buf[0])
            l_chunk_num = l_chunk_num + 1 
            return num_val_buf[0], val_buf
          elseif ( my_name == "cnt" ) then 
            vectors.val:put_chunk(val_buf, num_val_buf[0])
            l_chunk_num = l_chunk_num + 1 
            return num_val_buf[0], cnt_buf
          else
            error("XXX")
          end
        end 
        --===================================================
      end -- end of while 
    end
    lgens[my_name] = gen
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
