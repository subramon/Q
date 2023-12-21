local ffi       = require 'ffi'
local Scalar    = require 'libsclr'
local cVector   = require 'libvctr'
local cutils    = require 'libcutils'
local cmem	= require 'libcmem'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'
local process_opt_args = require 'Q/OPERATORS/PRINT/lua/process_opt_args'
local process_filter = require 'Q/OPERATORS/PRINT/lua/process_filter'
local cprint    = require 'Q/OPERATORS/PRINT/lua/cprint'

-- this implementation works but is not particularly fast - we are 
-- crossing the Lua/C boundary much too often. a faster version would
-- use get_chunk. For later TODO P3
local print_csv = function (
  inV,  --- table of lVectors to be printed
  opt_args
  )
  -- processing opt_args of print_csv
  local V -- table of vectors to be printed in desired order
  local opfile -- file to write output to 
  local filter -- if we don't want all rows
  local lenV -- length of vectors, must be same for all vectors
  local hdr --- optional header line for output
  local formats -- how a particular column should be printed
  local max_num_in_chunk -- must be same for all vectors
  local is_html -- format for output, default is false => CSV
  V, opfile, is_html, filter, lenV, max_num_in_chunk, hdr, formats = 
    process_opt_args(inV, opt_args)
  if ( opfile ) then 
    cutils.delete(opfile)
  end
  --======================
  if ( hdr ) then 
    if ( opfile ) then 
      assert(cutils.write(opfile, hdr .. "\n"))
    else
      print(hdr .. "\n")
    end
  end 
  --======================
  local lb, ub, where = process_filter(filter, lenV)
  local nV = #V
  if ( opt_args and opt_args.impl == "C" ) then 
    print("Using C print implementation")
    assert(cprint(opfile, is_html, where, formats, lb, ub, V, max_num_in_chunk))
    print("Done  C print implementation")
    return true 
  end
  print("Using Lua print implementation")
  -- Now we have a slower Lua implementation
  -- Output ALWAYS go to a file, to stdout if no filename given 
  local fp = nil -- file pointer
  if ( ( not opfile )  or ( opfile == "" ) ) then
    io.output(io.stdout)
  else
    assert(type(opfile) == "string")
    fp = assert(io.open(opfile, "a+"))
    io.output(fp)
  end
  if ( lenV == 0 ) then io.close(fp) return true end 
  --==========================================
  
  local bfalse = Scalar.new(false, "BL")
  if ( is_html ) then 
    io.write("<HTML>\n")
    io.write("  <table>\n")
  end
  for rowidx = lb, ub-1 do -- NOTE the -1 it is important
   if ( is_html ) then io.write("    <tr> ") end
    local to_print = true
    if ( where ) then 
      local  w = assert(where:get1(rowidx))
      if ( w == bfalse ) then 
        to_print = false
      end
    end
    if ( to_print ) then 
      for colidx, v in ipairs(V) do
        if ( is_html ) then io.write("<td> ") end
        local  s, s_nn = assert(v:get1(rowidx))
        --======================================================
        local to_pr = true 
        if ( s_nn ) then 
          assert(type(s_nn) == "Scalar" ) 
          to_pr = s_nn:to_bool() 
        end
        if ( not to_pr ) then 
          assert(io.write(""))
        else
          if ( type(s) == "Scalar" ) then 
            if ( v:qtype() == "SC" ) then 
              assert(io.write(cutils.quote_str(s:to_str())))
            elseif ( ( v:qtype() == "TM" ) or ( v:qtype() == "TM1" ) ) then
              error("NOT IMPLEMENTED")
            else
              assert(io.write(s:to_str()))
            end 
          elseif ( type(s) == "CMEM" ) then 
            -- TODO P1 Can we delete this else case?
            -- ffi.string is necessary to convert to Lua string
            local instr = ffi.string(get_ptr(s, "SC"))
            assert(io.write(cutils.quote_str(instr)))
          else
            error("")
          end
        end
        --======================================================
        if ( colidx == nV ) then 
          if ( is_html ) then 
            assert(io.write("</tr>\n"), "Write failed")
          else
            assert(io.write("\n"), "Write failed")
          end
        else
          if ( is_html ) then 
            assert(io.write(" </td> "), "Write failed")
          else
            assert(io.write(","), "Write failed")
          end
        end
      end
    end
  end
  if ( is_html ) then 
    io.write("  </table>\n")
    io.write("</HTML>\n")
  end
  if ( fp ) then io.close(fp)  end 
  return true
end
return require('Q/q_export').export('print_csv', print_csv)
