#!/bin/bash
set -e
bison -d --debug -v qgrammar.y
flex qgrammar.l  
cat qgrammar.tab.c | \
      sed s/'^  return yyresult;/BYE: return yyresult;/'g > _x.c;\
      mv _x.c qgrammar.tab.c
gcc -g -std=gnu99 -DYYDEBUG=1 -I../AUX/ driver.c q2json.c  \
  ../AUX/extract_S.c \
  ../AUX/auxil.c \
  ../AUX/mmap.c \
  qgrammar.tab.c -lfl -o qparser 
# echo PREMATURE; exit 1; 

vg="valgrind   --leak-check=full --show-leak-kinds=all "
vg=" "
$vg ./qparser in1.txt out1.json
