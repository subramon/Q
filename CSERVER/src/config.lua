local T = {}
T[#T+1] = " -g -std=gnu99 -Wall -fPIC -fopenmp -mavx2 -mfma "
T[#T+1] = " -Wall -Waggregate-return -Wcast-align -Wmissing-prototypes "
T[#T+1] = " -Wnested-externs -Wshadow -Wwrite-strings -Wunused-variable "
T[#T+1] = " -Wunused-parameter -Wno-pedantic -Wno-unused-label "
T[#T+1] = " fsanitize=address -fno-omit-frame-pointer -fsanitize=undefined"
T[#T+1] = " -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith "
T[#T+1] = " Wmissing-declarations -Wredundant-decls -Wnested-externs "
T[#T+1] = " Wshadow -Wcast-qual -Wcast-align -Wwrite-strings "
T[#T+1] = " Wold-style-definition -Wsuggest-attribute=noreturn "
T[#T+1] = " -Wduplicated-cond -Wmisleading-indentation -Wnull-dereference "
T[#T+1] = " Wduplicated-branches -Wrestrict "

return  { 
  port = 8080,
  QC_FLAGS = table.concat(T, " "),
}

