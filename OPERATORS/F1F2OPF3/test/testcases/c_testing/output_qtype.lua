-- get output qtype. in case of vvrem, logic is different from others
local promote = require 'Q/UTILS/lua/promote'
local qconsts = require 'Q/UTILS/lua/q_consts'
local fns = {}

fns.vvrem = function(qtype_input1, qtype_input2)  
  local qtype
  local sz1 = assert(qconsts.qtypes[qtype_input1].width)
  local sz2 = assert(qconsts.qtypes[qtype_input2].width)
  if ( sz1 < sz2 ) then 
    qtype = qtype_input1  
  else
    qtype = qtype_input2
  end
  return qtype  
end

fns.promote = function(qtype_input1, qtype_input2)  
  local qtype = promote(qtype_input1, qtype_input2)
  return qtype  
end

fns.concat = function(qtype_input1, qtype_input2)  
  local qtype 
  if ( qtype_input1 == "I4" ) then 
    qtype = "I8"
  elseif( qtype_input1 == "I2" ) then 
    if ( qtype_input2 == "I4" ) then
      qtype = "I8"
    elseif( qtype_input2 == "I2" ) then
      qtype = "I4"
    elseif( qtype_input2 == "I1" ) then
      qtype = "I4"
    end
  elseif( qtype_input1 == "I1" ) then 
    if ( qtype_input2 == "I4" ) then
      qtype = "I8"
    elseif( qtype_input2 == "I2" ) then
      qtype = "I4"
    elseif( qtype_input2 == "I1" ) then
      qtype = "I2"
    end
  end
  return qtype  
end

return fns