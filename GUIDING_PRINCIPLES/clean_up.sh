#!/bin/bash
set -e
DIR_PATH=$1
test -d $DIR_PATH || (bash my_print.sh "No directory passed to cleanup" 1; exit 1)
bash my_print.sh $DIR_PATH
find $DIR_PATH -name "*.o" -o -name "_*" | xargs rm -f
