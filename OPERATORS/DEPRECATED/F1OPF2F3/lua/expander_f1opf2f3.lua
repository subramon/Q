local qconsts = require 'Q/UTILS/lua/q_consts'
local Column = require 'Q/RUNTIME/COLUMN/code/lua/Column'
local ffi = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local function expander_f1opf2f3(a, x, optargs )
    -- Get name of specializer function. By convention
    local sp_fn_name = "Q/OPERATORS/F1F2OPF3/lua/" .. a .. "_specialize"
    local spfn = require(sp_fn_name)
    local status, subs, tmpl = pcall(spfn, x:fldtype())
    assert(status, "Failure in specializer " .. sp_fn_name)
    local func_name = assert(subs.fn)
    local out1_qtype = assert(subs.out1_qtype)
    local out1_width = qconsts.qtypes[out1_qtype].width
    local out2_qtype = assert(subs.out2_qtype)
    local out2_width = qconsts.qtypes[out2_qtype].width

    local x_coro = assert(x:wrap(), "wrap failed for x")
    local coro = coroutine.create(function()
      local x_status, x_len, x_chunk, nn_x_chunk 
      local x_chunk_size = x:chunk_size()
      local out1_buff = q_core.malloc(x_chunk_size * out1_width)
      local out2_buff = q_core.malloc(x_chunk_size * out2_width)
      assert(not x:has_nulls(), "Not set up for null values")
      x_status = true
      while (x_status) do
        x_status, x_len, x_chunk, nn_x_chunk = coroutine.resume(x_coro)
        if x_status then
          print("x details:", x_status, x_chunk, x_len)
          assert(x_len > 0)
          q[func_name](x_chunk, x_len, out1_buff, out2_buff) 
          coroutine.yield(x_len, buff, nn_buff)
        end
      end
    end)
    print("================")
    dbg()
    local col1 = Column{gen=coro, nn=(nn_buf ~= nil), field_type=out1_qtype}
end

return expander_f1opf2f3
