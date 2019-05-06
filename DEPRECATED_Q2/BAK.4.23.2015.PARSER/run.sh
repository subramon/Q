#!/bin/bash
set -e
bison -d --debug -v qgrammar.y
flex qgrammar.l  
cat qgrammar.tab.c | \
      sed s/'^  return yyresult;/BYE: return yyresult;/'g > _x.c;\
      mv _x.c qgrammar.tab.c
# gcc -g -std=gnu99 -DYYDEBUG=1 extract_S.c auxil.c mmap.c lex.yy.c snazzle.tab.c -lfl -o snazzle
gcc -g -std=gnu99 -DYYDEBUG=1 driver.c q2json.c extract_S.c \
  auxil.c mmap.c qgrammar.tab.c -lfl -o qparser
# echo PREMATURE; exit 1; 

vg=" "
vg="valgrind   --leak-check=full --show-leak-kinds=all "
$vg ./qparser in1.txt out1.json
