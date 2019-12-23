
assert(type(arg) == "table")
local mode = arg[1]

local timers = {
  "check ",
  "clone ",
  "flush ",
  "free ",
  "get1 ",
  "get_all ",
  "get_chunk ",
  "new ",
  "put1 ",
  "put_chunk ",
  "rehydrate_single ",
  "rehydrate_multi ",
  "start_write ",

  "malloc ",
  "memcpy ",
  "memset ",
}

local function gen_timers_code(
  mode
  )
  local T = {}
  if ( mode == "reset" ) then 
    T[#T+1] = "void g_reset_timers( void) { "
    for k, v in pairs(timers) do 
      T[#T+1] = "t_" .. v .. " = 0 ; "  ..  "n_" .. v .. " = 0 ; "
    end
    T[#T+1] = "}"
  elseif ( mode == "print" ) then 
    T[#T+1] = "void g_print_timers( void) { "
    for k, v in pairs(timers) do 
      T[#T+1] = "fprintf(stdout, \"0,check,%u,%\" PRIu64 \"\\n\", " ..
        "n_" .. v .. ", t_" .. v .. ");"
    end
    T[#T+1] = "}"
  elseif ( mode == "define" ) then 
    for k, v in pairs(timers) do 
      T[#T+1] = "my_extern uint64_t t_" .. v .."; my_extern uint32_t n_" .. v .. ";"
    end
  else
    assert(nil, "Unknown mode = [" .. mode .. "]")
  end
  print(table.concat(T, "\n"))
end
-- return gen_timers_code
-- gen_timers_code("reset")
-- gen_timers_code("print")
-- gen_timers_code("define")
gen_timers_code(mode)
