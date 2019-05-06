#!/usr/bin/python
import re
import sys
import pdb
conv_table = {}
in_file_name = sys.argv[-2]
out_file_name = sys.argv[-1]
for arg in sys.argv[1:-2]:
    values = arg.split('=')
    if len(values) != 2:
        sys.stderr.write("Incorrect number of = in {}\n".format(arg))
        sys.exit(1)
    #values[0] = re.escape('$' + values[0])
    if values[0] in conv_table.keys():
        sys.stderr.write("Same key repeated twice {}\n".format(values[0]))
        sys.exit(1)
    conv_table[values[0]] = values[1]
pattern_str =r'\b(' + '|'.join(conv_table.keys()) + r')\b'
pattern = re.compile(pattern_str)
with open(in_file_name, "r") as f_in:
    value = f_in.read()
    result = pattern.sub(lambda x: conv_table[x.group()], value)
if out_file_name != "-":
    with open(out_file_name, "w+") as f_out:
        f_out.write(result)
else:
    print (result)
