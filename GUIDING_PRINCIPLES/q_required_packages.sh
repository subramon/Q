bash my_print.sh "STARTING: Installing Q-required packages"
#for now included pkg "penlight" as our Q build is using it
sudo luarocks install penlight
bash my_print.sh "COMPLETED: Installing Q-required packages"
