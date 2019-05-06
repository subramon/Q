#!/bin/bash
set -e
which gcc
GCCVER=$(gcc --version | awk '/gcc /{print $4;exit 0;}')
GCCVER=$(echo "${GCCVER//.}")
REQUIRED=5.4.0 #specify here the required gcc version
REQUIRED=$(echo "${REQUIRED//.}")
if [ $(bc <<< "$GCCVER >= $REQUIRED") -eq 1 ];then
  bash my_print.sh "STARTING: GCC version is appropriate"
else
  #TODO: Error msg color red
  bash my_print.sh "Required GCC version is 5.4.0"
  exit 1;
fi


