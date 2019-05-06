Packages/dependencies required for CSERVER:
sudo apt-get install libcurl4-openssl-dev

Steps to run CSERVER
1. cd Q	
2. source setup -f
3. cd Q/CSERVER/hello_world/src/
5. make clean
6. make
7. export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/newvm/WORK/Q/CSERVER/hello_world/libevent-2.1.8-stable/.libs/"
8. ./q_httpd

Steps to run client:
1. cd Q
2. source setup -f
3. cd CSERVER/hello_world/client/
4. bash q_client.sh
5. ./qc localhost 8000

Example:
Client side:
>> col=Q.mk_col({1,2,3,4,5}, "I1")
>> return(Q.print_csv(col,{ opfile= ""}))
>> Q.print_csv(col)

Note: 
If any Q operator is expected to return some value(string/number), then a explicit return call is expected(i.e. return(Q.print_csv(col,{ opfile= ""})))

TODO's:
1. Q.print_csv(col) will not output the value of col on screen, need to change the Q.print_csv code
