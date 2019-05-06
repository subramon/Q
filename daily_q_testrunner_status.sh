#!/bin/bash

set +e
export Q_SRC_ROOT="$HOME/WORK/Q"
cd $Q_SRC_ROOT

#cleaning up of data files in local/Q/data/ directory
rm -f ../../local/Q/data/_*
rm -f ../../local/Q/trace/qcore.log

#cleaning up files in git repo
git checkout .
git clean -fd
#pulling recent changes in git repo
git pull

echo $Q_SRC_ROOT
#setting environment variables
source $Q_SRC_ROOT/setup.sh -f

rm -f ../../local/Q/lib/lib*.so
cd $Q_SRC_ROOT/UTILS/build
#running build
build_cleanup_heading="------------OUTPUT of build cleanup--------------------------------------"
build_cleanup_output=$(make clean 2>&1)
build_output_heading="------------OUTPUT of build scripts--------------------------------------"
build_output=$(make static 2>&1)

cd ../../
#running q_testrunner from Q_SRC_ROOT and dump output in temporary file
luajit $Q_SRC_ROOT/TEST_RUNNER/q_testrunner.lua i $Q_SRC_ROOT > $HOME/q_testrunner_output.txt


#cmd to get last line of output of q_testrunner
q_test_runner_result=$(tail -n1 < $HOME/q_testrunner_output.txt)

#cmd to mail the output of q_testrunner
echo $q_test_runner_result | /usr/bin/mail -s "Q Unit Tests" Subramonian@gmail.com -A $HOME/q_testrunner_output.txt
