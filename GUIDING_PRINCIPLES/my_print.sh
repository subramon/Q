#!/bin/bash
set -e
COLOR_RED='\e[0;91m'
COLOR_GREEN='\e[0;92m'
COLOR_NORMAL='\e[0m'
if [ -z "$2" ] ; then
  echo -e "$COLOR_GREEN AIO: $1 $COLOR_NORMAL"
else
  echo -e "$COLOR_RED AIO: $1 $COLOR_NORMAL"
fi
