#!/bin/bash
set -e
source setup.sh #- sets up environment variables
bash packages.sh
bash from_source.sh
bash lua_packages.sh
# to make things more comfortable
cp ~/Q/GUIDING_PRINCIPLES/SHELL_UTILS/vimrc  $HOME/.vimrc
cp -r ~/Q/GUIDING_PRINCIPLES/SHELL_UTILS/vim $HOME/.vim
cp -r ~/Q/GUIDING_PRINCIPLES/SHELL_UTILS/bashrc $HOME/.bashrc
cp -r ~/Q/GUIDING_PRINCIPLES/SHELL_UTILS/git_prompt.sh $HOME/
#-------------------------
cd $HOME/Q/UTILS/build/
make clean && make
luajit test_qd.lua
lua    test_qd.lua
echo "Q installed"
