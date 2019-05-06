#!/bin/bash
bash cleanup.sh
bash generate_static_checker.sh
bash generate_white_list.sh
lua f1f2opf3_generator.lua
cd ../../PRIMITIVES/src
bash README.sh
cd -
echo "ALL DONE"
