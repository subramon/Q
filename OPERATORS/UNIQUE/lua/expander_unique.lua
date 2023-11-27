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

  local status, subs = pcall(spfn, a:fldtype())
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  qc.q_add(subs)
  assert(qc[func_name], "Symbol not defined " .. func_name)

  -- TODO P1 Check that a is sorted. a = sort_utility(a)
  
  -- track how much of input you have consumed 
  local num_consumed = cmem.new("uint64_t[?]", 1)
  num_consumed[0] = 0
  -- how much of input buffer has been filled up
  local num_val_buf = cmem.new("uint64_t[?]", 1)
  num_val_buf[0] = 0
  -- whether val_buf will overflow if we consume more input
  local overflow = cmem.new("bool[?]", 1)
  overflow[0] = false

  local l_chunk_num = 0
  -- this is tricky part where we create 2 generators
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
  
      while ( true ) do 
        local in_len, in_chunk = a:chunk(in_chunk_idx)
        if in_len == 0 then
          if ( num_val_buf[0] > 0 ) then 
            if ( my_name == "val" ) then 
              cnt_vec:put_chunk(cnt_buf, nil, num_val_buf[0])
              return num_val_buf[0], val_buf
            elseif ( my_name == "cnt" ) then 
              val_vec:put_chunk(val_buf, nil, num_val_buf[0])
              return num_val_buf[0], cnt_buf
            else
              error("XXX")
            end
          else
            val_buf:delete()
            cnt_buf:delete()
          end
        end
        --======================================================
        
        local in_ptr  = ffi.cast(subs.val_ctype .. "*",  get_ptr(in_chunk))
        local val_ptr = ffi.cast(subs.val_ctype .. "*",  get_ptr(val_buf))
        local cnt_ptr = ffi.cast(subs.cnt_ctype .. "*",  get_ptr(cnt_buf))
  
        local status = qc[func_name](in_ptr, in_len, val_ptr, cnt_ptr, 
        num_consumed, num_val_buf, subs.max_num_in_chunk, overflow)
        assert(status == 0, "C error in UNIQUE")
        -- If output buffer is (truly) full then return it 
        if ( overflow[0] == true ) then 
          if ( my_name == "val" ) then 
            cnt_vec:put_chunk(cnt_buf, nil, num_val_buf[0])
            return num_val_buf[0], val_buf
          elseif ( my_name == "cnt" ) then 
            val_vec:put_chunk(val_buf, nil, num_val_buf[0])
            return num_val_buf[0], cnt_buf
          else
            error("XXX")
          end
        end 
        --===================================================
        l_chunk_num = l_chunk_num + 1 
      end -- wnd of while 
    end
    lgens[my_name] = gen
  end
  local val_args = {}
  val_args.qtype = subs.val_qtype
  val_args.max_num_in_chunk = subs.max_num_in_chunk
  val_args.has_nulls = false
  val_args.gen = lgens["val"]

  local cnt_args = {}
  cnt_args.qtype = subs.cnt_qtype
  cnt_args.max_num_in_chunk = subs.max_num_in_chunk
  cnt_args.has_nulls = false
  cnt_args.gen = lgens["cnt"]

  return lVector(val_args), lVector(cnt_args)
end
return expander_unique
