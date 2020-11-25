#!/bin/bash
set -e
if [ $# != 2 ]; then echo Failure; exit 1; fi
src=$1
dst=$2
if [ "$src" == "$dst" ];then echo Failure; exit 1; fi
test -f $src
if [ $? == 0 ]; then 
  cp $src $dst
fi
