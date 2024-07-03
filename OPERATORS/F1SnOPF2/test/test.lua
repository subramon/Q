local Q = require 'Q'
local Scalar = require 'libsclr'
local tests = {}
tests.t1 = function()
  local qtypes = 
   { "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8", "F4", "F8", }
  for _, qtype in ipairs(qtypes) do
    local n = 127
    local x = Q.seq({start = 0, by = 1, len = n, qtype = qtype})
    for iter = 1, 3 do 
      local sclrs
      if ( iter == 1 ) then 
        sclrs = 1
      elseif ( iter == 2 ) then 
        sclrs = { 1, 2, 3, 4, 5 }
      elseif ( iter == 3 ) then 
        sclrs = {}
        for k = 1, 5 do 
          sclrs[k] = Scalar.new(k, qtype)
        end
      else
        error("XXX")
      end
      local y = Q.vSeq(x, sclrs)
      assert(type(y) == "lVector")
      assert(y:qtype() == "BL")
      local r = Q.sum(y)
      local n1, n2 = r:eval()
      if ( iter == 1 ) then
        assert(n1:to_num() == 1)
      else
        assert(n1:to_num() == 5)
      end
      y:delete()
      r:delete()
      local msg = {}; 
      msg[#msg+1] =  "Test succeeded for qtype " 
      msg[#msg+1] = qtype
      if ( iter == 1 ) then
        msg[#msg+1] = " case of single number "
      elseif ( iter == 2 ) then
        msg[#msg+1] = " case of table of numbers "
      elseif ( iter == 3 ) then
        msg[#msg+1] = " case of table of Scalars "
      end
      print(table.concat(msg, " "))
    end
    x:delete()
  end
end
tests.t1()
-- return tests
