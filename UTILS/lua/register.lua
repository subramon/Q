-- How to register a function with Q that uses an expander
-- TODO P1: Make sure that qname has not been registered before
local qconsts = require 'Q/UTILS/lua/q_consts'

local function register(expander, qname, ...)
  assert(expander and (type(expander) == "string") and (#expander > 0))
  assert(qname    and (type(qname)    == "string") and (#qname    > 0))
  
  local qfn = function(...)
    local x = assert(require(expander))
    local rvals = {pcall(x, qname, unpack(arg))}
    if ( #rvals == 0 ) then return nil end 
    local status = rvals[1]
    if ( not status ) then 
      print(qname .. " failed"); 
      if #rvals > 1 then print(rvals[2]) end
      return nil 
    end
    local xvals = {}
    for k, v in ipairs(rvals) do 
      if ( k > 1 ) then xvals[#xvals+1] = rvals[k] end
    end
    return unpack(xvals)
  end
  require('Q/q_export').export(qname, qfn)
  return qfn
end
return require('Q/q_export').export('register', register)
