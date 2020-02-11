
assert(type(arg) == "table")
local mode = arg[1]

local timers = {
  "check ",
  "clone ",
  "flush ",
  "free ",
  "get1 ",
  "start_read ",
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
  elseif ( mode == "struct" ) then 
    T[#T+1] = " typedef struct _vec_timers_type { "
    for k, v in pairs(timers) do 
      T[#T+1] = "uint64_t t_" .. v .."; uint32_t n_" .. v .. ";"
    end
    T[#T+1] = " } VEC_TIMERS_TYPE; ";
  else
    assert(nil, "Unknown mode = [" .. mode .. "]")
  end
  print(table.concat(T, "\n"))
end
-- return gen_timers_code
-- gen_timers_code("reset")
-- gen_timers_code("print")
-- gen_timers_code("struct")
gen_timers_code(mode)
