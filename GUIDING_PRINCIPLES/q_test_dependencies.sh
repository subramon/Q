bash my_print.sh "STARTING: Installing Q-test dependencies using luarocks"
## Reason: removing luaposix as,
## capturing timers can be done using qc.RDTSC() and
## modifying the env variablea within the same luajit instance will not work
## as env variables are now treated as Q consts
#sudo luarocks install luaposix
sudo luarocks install penlight #pl lib has been used for Q unit test
## Reason: as we are not doing code coverage for now -Ramesh
#sudo luarocks install luacov
## TODO: need to add all dependencies in test mode to run sklearn's DT
## like pip3, sklearn, pandas, numpy ...
bash my_print.sh "COMPLETED: Installing Q-test dependencies using luarocks"
