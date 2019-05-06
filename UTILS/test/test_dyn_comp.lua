local tests = {}

tests.compile = function()
  -- require 'strict'
  package.loaded['Q/UTILS/lua/q_core'] = nil
  -- package.loaded['ffi'] = nil
  local ffi = require 'ffi'
  local plfile = require 'pl.file'
  local x = require 'Q/UTILS/lua/compiler'
  local dotc = [[ #include "_boom.h"
  int boom(void){
    printf("hello\n");
    return 0;
  }
  ]]
  local doth = [[ #include <stdio.h>
  extern int boom(void);
  ]]
  -- local cdef = x('#include <stdio.h>\nint boom(void);', '#include <stdio.h>\nint boom(void){printf("hello\n"); return 0;}', 't')
  -- print(doth, dotc, 'boom')
  local h_path, so_path = "./boom.h" , "./libboom.so"
  x(doth, h_path, dotc, so_path, 'boom')
  ffi.cdef(plfile.read(h_path))
  local X = ffi.load(so_path)
  return assert(tonumber(X.boom()) == 0 )
end

tests.qc_compile = function()
  local Q_SRC_ROOT = os.getenv('Q_SRC_ROOT')
  local Q_ROOT = os.getenv('Q_ROOT')
  os.execute(string.format("rm %s/include/boom.h", Q_ROOT))
  os.execute(string.format("rm %s/lib/libboom.so", Q_ROOT))
  local dotc = [[ #include "./boom.h"
  int boom(){
    printf("hello\n");
    return 0;
  }
  ]]
  local doth = [[ #include <stdio.h>
  extern int boom(void);
  ]]
 
  assert(os.execute([[ luajit -e "
  local qc = require 'Q/UTILS/lua/q_core'
  assert( qc.q_add(doth, dotc, 'boom') == true)
  assert( qc.q_add(doth, dotc, 'boom') == false)
  qc.boom()
 "]]))
  return true
end

tests.qc_lib_addition = function()
  local Q_SRC_ROOT = os.getenv('Q_SRC_ROOT')
  local Q_ROOT = os.getenv('Q_ROOT')
  os.execute(string.format("rm %s/include/boom.h", Q_ROOT))
  os.execute(string.format("rm %s/lib/libboom.so", Q_ROOT))
 assert(os.execute(string.format(
  [[luajit -e 'require "Q/UTILS/test/test_dyn_comp".qc_compile()']], Q_SRC_ROOT)) == 0, "Compiling lib must pass")
  assert(os.execute([[luajit -e 'require "Q/UTILS/lua/q_core".boom()']]))
  return true
end

return tests
