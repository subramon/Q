Run below commands from 'luajit_vs_luaffi_independent_test' directory

- Access 'luajit_vs_luaffi_independent_test' directory
$ cd experimental/luajit_vs_luaffi/luajit_vs_luaffi_independent_test/

- Run test (provide required interpreter name as first argument)
Note: To execute test with 'lua' as an interpreter, build luaffi and copy ffi.so to the current directory
$ bash run_vvadd.sh <luajit/lua>

You will get C execution time on console

Note: num_elements are set to 100000000, if you want to update num_elements then modify run_vvadd.lua
