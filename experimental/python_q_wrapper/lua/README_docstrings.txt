In Q to get docstring of a particular operator:
Usage: Q.operator_name("help")
for e.g.: Q.mk_col("help")

The stub_file_generator creates q_op_stub_file.pyi which has the signature for all Q operators

To create this q_op_stub_file.pyi file which will be used by python-Q wrapper:
Steps to run:
1. cd Q/experimental/python_q_wrapper/lua/
2. luajit stub_file_generator.lua
This creates "q_op_stub_file.pyi" in current directory 

TODO:
1) The docstrings are to be added for all the Q operators

2) TRIGGER point for this stub_file_generator:
Triggering point to create this stub_file("q_op_stub_file.pyi") in python-Q wrapper will be
when we import Q for the first time in python script
and this "q_op_stub_file.pyi" should be deleted when we build Q.

Note: Currently the docstring has been added for Q.mk_col and Q.print_csv operator and
also for F1F2OPF3 operators in pkg_f1f2opf3.lua which is a wrapper template file
