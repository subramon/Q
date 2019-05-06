cat vvadd_white_list.lua | \
  sed s'/vvadd_/vvsub_/'g > vvsub_white_list.lua
cat vvadd_white_list.lua | \
  sed s'/vvadd_/vvmul_/'g > vvmul_white_list.lua
cat vvadd_white_list.lua | \
  sed s'/vvadd_/vvdiv_/'g > vvdiv_white_list.lua
