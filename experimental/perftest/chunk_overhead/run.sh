#!/bin/bash
set -e
TIMES=5

run () {
   for i in $(seq 1 ${TIMES})
   do
      rm -rf ${Q_DATA_DIR}/* &>/dev/null
      printf "%s\t%s\t" "$1" "$3"
      luajit $2 $3
   done
}


gcc driver.c -o comp
# ./comp 1 /tmp/one.bin
# ./comp 10 /tmp/ten.bin
# ./comp 100 /tmp/hun.bin
# ./comp 1000 /tmp/tho.bin
# ./comp 10000 /tmp/tent.bin
# ./comp 100000 /tmp/hunt.bin
# ./comp 1000000 /tmp/mil.bin
# ./comp 10000000 /tmp/tmil.bin
# ./comp 100000000 /tmp/hmil.bin
# ./comp 200000000 /tmp/thmil.bin
# ./comp 300000000 /tmp/thhmil.bin
# ./comp 400000000 /tmp/fhmil.bin
# ./comp 500000000 /tmp/fihmil.bin
# ./comp 600000000 /tmp/shmil.bin
# ./comp 700000000 /tmp/sehmil.bin
 ./comp 800000000 /tmp/ehmil.bin
# ./comp 900000000 /tmp/nhmil.bin
# ./comp 1000000000 /tmp/bil.bin


# run "q" test_q.lua /tmp/one.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/one.bin
# run "c" test_c.lua /tmp/one.bin
# 
# run "q" test_q.lua /tmp/ten.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/ten.bin
# run "c" test_c.lua /tmp/ten.bin
# 
# run "q" test_q.lua /tmp/hun.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/hun.bin
# run "c" test_c.lua /tmp/hun.bin
# 
# run "q" test_q.lua /tmp/tho.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/tho.bin
# run "c" test_c.lua /tmp/tho.bin
# 
# run "q" test_q.lua /tmp/tent.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/tent.bin
# run "c" test_c.lua /tmp/tent.bin
# 
# run "q" test_q.lua /tmp/hunt.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/hunt.bin
# run "c" test_c.lua /tmp/hunt.bin
# 
# run "q" test_q.lua /tmp/mil.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/mil.bin
# run "c" test_c.lua /tmp/mil.bin
# 
# run "q" test_q.lua /tmp/tmil.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/tmil.bin
# run "c" test_c.lua /tmp/tmil.bin
# 
# run "q" test_q.lua /tmp/hmil.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/hmil.bin
# run "c" test_c.lua /tmp/hmil.bin
# 
# run "q" test_q.lua /tmp/thmil.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/thmil.bin
# run "c" test_c.lua /tmp/thmil.bin
# 
# run "q" test_q.lua /tmp/thhmil.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/thhmil.bin
# run "c" test_c.lua /tmp/thhmil.bin
# 
# run "q" test_q.lua /tmp/fhmil.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/fhmil.bin
# run "c" test_c.lua /tmp/fhmil.bin
# 
# run "q" test_q.lua /tmp/fihmil.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/fihmil.bin
# run "c" test_c.lua /tmp/fihmil.bin
# 
# run "q" test_q.lua /tmp/shmil.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/shmil.bin
# run "c" test_c.lua /tmp/shmil.bin
# 
# run "q" test_q.lua /tmp/sehmil.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/sehmil.bin
# run "c" test_c.lua /tmp/sehmil.bin
# 
 run "q" test_q.lua /tmp/ehmil.bin
 run "q_no_memo" test_q_no_memo.lua /tmp/ehmil.bin
 run "c" test_c.lua /tmp/ehmil.bin

# run "q" test_q.lua /tmp/nhmil.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/nhmil.bin
# run "c" test_c.lua /tmp/nhmil.bin

# run "q" test_q.lua /tmp/bil.bin
# run "q_no_memo" test_q_no_memo.lua /tmp/bil.bin
# run "c" test_c.lua /tmp/bil.bin

