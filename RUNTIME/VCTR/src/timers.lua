
assert(type(arg) == "table")
local mode = arg[1]

local timers = {
  "check ",
  "clone ",
  "delete_chunk_file ",
  "delete_master_file ",
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
  "shutdown ",
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
    T[#T+1] = "#include \"struct_timers.h\"";
    T[#T+1] = "void reset_timers( VEC_TIMERS_TYPE *ptr_T) { "
    for k, v in pairs(timers) do 
      T[#T+1] = "ptr_T->t_" .. v .. " = 0 ; "  ..  "ptr_T->n_" .. v .. " = 0 ; "
    end
    T[#T+1] = "}"
  elseif ( mode == "print" ) then 
    T[#T+1] = "#include \"struct_timers.h\"";
    T[#T+1] = "void print_timers( VEC_TIMERS_TYPE *ptr_T) { "
    for k, v in pairs(timers) do 
      T[#T+1] = "fprintf(stdout, \"0,check,%u,%\" PRIu64 \"\\n\", " ..
        "ptr_T->n_" .. v .. ", ptr_T->t_" .. v .. ");"
    end
    T[#T+1] = "}"
  elseif ( mode == "struct" ) then 
    T[#T+1] = "#ifndef _STRUCT_TIMERS "
    T[#T+1] = "#define _STRUCT_TIMERS "
    T[#T+1] = " typedef struct _vec_timers_type { "
    for k, v in pairs(timers) do 
      T[#T+1] = "uint64_t t_" .. v .."; uint32_t n_" .. v .. ";"
    end
    T[#T+1] = " } VEC_TIMERS_TYPE; "
    T[#T+1] = "#endif "
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
