#!/bin/bash
set -e
if [ $# != 2 ]; then echo Failure; exit 1; fi
src=$1
dst=$2
if [ "$src" == "$dst" ];then echo Failure; exit 1; fi
set +e
test -f $src
if [ $? == 0 ]; then 
  set -e
  cp $src $dst
else
  echo "Nothing to do"
fi
