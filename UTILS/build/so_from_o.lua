local function so_from_o()
  --===== Combine .o files into single .so file
  local lflags = qconsts.Q_LINK_FLAGS
  assert( ( type(lflags) == "string") and ( #lflags > 0 ) )
  
  local q_c = table.concat(q_c_files, " ")
  --  "gcc %s %s -I %s %s -lgomp -pthread -shared -o %s", 
  local q_cmd = string.format(" gcc %s/*.o  %s -o %s", 
    odir, lflags, tgt_so)
  local status = os.execute(q_cmd)
  assert(status, q_cmd)
  assert(plpath.isfile(tgt_so), "Target " .. tgt_so .. " not created")
  print("Successfully created " .. tgt_so)
  pldir.copyfile(tgt_so, final_so)
  print("Copied " .. tgt_so .. " to " .. final_so)
end
return so_from_o
