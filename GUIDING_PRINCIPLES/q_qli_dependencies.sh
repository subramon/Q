bash my_print.sh "STARTING: Installing Q-qli dependencies using luarocks"
#not needed right now
#sudo luarocks install luaposix
#sudo luarocks install luv
#sudo luarocks install busted
#sudo luarocks install luacov
#sudo luarocks install cluacov
sudo luarocks install http      # for QLI
sudo luarocks install linenoise # for QLI
sudo apt-get install libcurl4-openssl-dev -y # for CSERVER
bash my_print.sh "COMPLETED: Installing Q-qli dependencies using luarocks"
