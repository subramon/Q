local ffi     = require 'ffi'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local qc      = require 'Q/UTILS/lua/qcore'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
-- TODO local sort_utility = require 'Q/OPERATORS/UNIQUE/lua/unique_sort_utility'

local function expander_unique(op, a)
  -- Verification
  assert(op == "unique")
  local sp_fn_name = "Q/OPERATORS/UNIQUE/lua/" .. op .. "_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs = pcall(spfn, a)
  if not status then print(subs) end
  local func_name = assert(subs.fn)
  qc.q_add(subs)
  assert(qc[func_name], "Symbol not defined " .. func_name)

  -- TODO P1 Check that a is sorted. a = sort_utility(a)
  -- TODO Improve 
  assert( ( a:get_meta("sort_order") == "asc") or
          ( a:get_meta("sort_order") == "dsc") or
          ( a:get_meta("grouped") == true) ) 
  --grouped is weaker but sufficient, sorted is stronger
  
  -- records which element of input buffer to examine
  local in_idx = ffi.new("uint32_t[?]", 1)
  -- how much of output buffer has been filled up
  local num_val_buf = ffi.new("uint32_t[?]", 1)
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
      -- print("Generating chunk ", chunk_num)
      -- START Create buffers for output 
      local val_buf = cmem.new(
        { size = subs.val_bufsz, name = "unique_val"})
      val_buf:zero()
      val_buf:stealable(true)
  
      local cnt_buf = cmem.new(
        { size = subs.cnt_bufsz, name = "unique_cnt"})
      cnt_buf:zero()
      cnt_buf:stealable(true)

      num_val_buf[0] = 0 -- indicates val_buf/cnt_buf are empty
      overflow[0] = false 
      -- STOP  Create buffers for output 
      --
      while ( true ) do 
        -- START Get access to input data 
        -- If first time OR you have consumed entire input chnk, get more
        if ( not in_buf ) then
          in_len, in_buf = a:get_chunk(in_chunk_num)
          in_idx[0] = 0
          -- print("A: Getting chunk " .. in_chunk_num)
        else
          -- if you have consumed everthing in current  chunk 
          if ( in_len == in_idx[0] ) then 
            a:unget_chunk(in_chunk_num)
            ----  print("X: Ungetting input chunk " .. in_chunk_num)
            if ( in_len < a:max_num_in_chunk() ) then
              -- there cannot be any more chunks in input 
              assert(a:is_eov())
              in_len = 0; in_buf = nil -- indicate end of input
            else
              in_chunk_num = in_chunk_num + 1 
              in_len, in_buf = a:get_chunk(in_chunk_num)
              in_idx[0] = 0
              -- print("B: Getting chunk " .. in_chunk_num)
            end
          else 
            -- print("Need to finish consuming input in chnk",in_chunk_num)
          end
        end
        -- STOP  Get access to input data 
        --=== START handle case where no more input 
        if in_len == 0 then
          -- print("NO MORE INPUT")
          if ( num_val_buf[0] == 0 ) then 
            val_buf:delete()
            cnt_buf:delete()
            return 0
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
        assert(status == 0, "C error in UNIQUE")


        -- If output buffer is (truly) full then return it 
        if ( overflow[0] == true ) then 
          -- print("Return from C code, in_len = ", in_len)
          -- print("Return from C code, in_idx = ", in_idx[0]);
          -- print("Return from C code, num_val_buf = ", num_val_buf[0])
          -- print("Return from C code, overflow = ", overflow[0]);
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
