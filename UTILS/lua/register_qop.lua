-- How to register a function with Q that uses an expander
-- TODO P1: Make sure that qname has not been registered before

local function pack(...)
  return { n = select("#", ...), ... }
end

local function register_qop(expander, qname, ...)
  assert(expander and (type(expander) == "string") and (#expander > 0))
  assert(qname    and (type(qname)    == "string") and (#qname    > 0))
  
  local qfn = function(...)
    --[[ CRAZY BUG: difference between Lua and LuaJIT
    -- I had local rvals = { pcall(x, qname, ...)} Worked with Lua 5.1
    -- I had to use variable T shown below to get it to work with LuaJIT
    --]]
    local T = pack(...) 
    
    local x = assert(require(expander))
    local rvals = {pcall(x, qname, unpack(T))}
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
return require('Q/q_export').export('register', register_qop)
