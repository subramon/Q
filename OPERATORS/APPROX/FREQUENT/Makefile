INCLUDES = -I../../SORT/gen_inc/ -I./gen_inc/ -I./inc/
SRC_INCLUDES = ../../SORT/gen_src/*.c gen_src/*.c

all: libapprox_frequent.so

all_for_dc:
	    echo "Nothing to do"

gen_inc/% gen_src/% : lua/*
	cd lua; luajit generator.lua

libapprox_frequent.so: gen_inc/* gen_src/*
	gcc ${SRC_INCLUDES} ${QC_FLAGS} ${INCLUDES} -shared -o libapprox_frequent.so

test: gen_inc/* gen_src/* test/testApproxFrequent.c
	gcc ${SRC_INCLUDES} ${QC_FLAGS} ${INCLUDES} 
	test/testApproxFrequent.c -o testApproxFrequent
	./testApproxFrequent

clean:
	rm -rf gen_src gen_inc
	rm -f libapprox_frequent.so
	rm -f testApproxFrequent
