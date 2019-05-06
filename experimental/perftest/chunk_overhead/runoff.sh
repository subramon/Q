#!/bin/bash
set -e
TIMES=5

run () {
   echo "${TIMES}"
   for i in $(seq 1 ${TIMES})
   do
      rm -rf ${Q_DATA_DIR}/* &>/dev/null
      printf "%s\t%s\t" "$1" "$3"
      luajit -joff $2 $3
   done
}


gcc driver.c -o comp
echo "gen length 1"
./comp 1 /tmp/one.bin
./comp 10 /tmp/ten.bin
./comp 100 /tmp/hun.bin
echo "gen length hun"
./comp 1000 /tmp/tho.bin
./comp 10000 /tmp/tent.bin
./comp 100000 /tmp/hunt.bin
./comp 1000000 /tmp/mil.bin
./comp 10000000 /tmp/tmil.bin
./comp 100000000 /tmp/hmil.bin
./comp 1000000000 /tmp/bil.bin
echo "gen length bil"


run "q" test_q.lua /tmp/one.bin
run "q_no_memo" test_q_no_memo.lua /tmp/one.bin
run "c" test_c.lua /tmp/one.bin

run "q" test_q.lua /tmp/ten.bin
run "q_no_memo" test_q_no_memo.lua /tmp/ten.bin
run "c" test_c.lua /tmp/ten.bin

run "q" test_q.lua /tmp/hun.bin
run "q_no_memo" test_q_no_memo.lua /tmp/hun.bin
run "c" test_c.lua /tmp/hun.bin

run "q" test_q.lua /tmp/tho.bin
run "q_no_memo" test_q_no_memo.lua /tmp/tho.bin
run "c" test_c.lua /tmp/tho.bin

run "q" test_q.lua /tmp/tent.bin
run "q_no_memo" test_q_no_memo.lua /tmp/tent.bin
run "c" test_c.lua /tmp/tent.bin

run "q" test_q.lua /tmp/hunt.bin
run "q_no_memo" test_q_no_memo.lua /tmp/hunt.bin
run "c" test_c.lua /tmp/hunt.bin

run "q" test_q.lua /tmp/mil.bin
run "q_no_memo" test_q_no_memo.lua /tmp/mil.bin
run "c" test_c.lua /tmp/mil.bin

run "q" test_q.lua /tmp/tmil.bin
run "q_no_memo" test_q_no_memo.lua /tmp/tmil.bin
run "c" test_c.lua /tmp/tmil.bin

run "q" test_q.lua /tmp/hmil.bin
run "q_no_memo" test_q_no_memo.lua /tmp/hmil.bin
run "c" test_c.lua /tmp/hmil.bin

run "q" test_q.lua /tmp/bil.bin
run "q_no_memo" test_q_no_memo.lua /tmp/bil.bin
run "c" test_c.lua /tmp/bil.bin

