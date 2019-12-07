C_FLAGS = -O4 -I src/ -Wall -fopenmp -std=gnu99
LIBS = -llapack -llapacke

INCS=\
     	-I../../UTILS/inc \
	-I../src/ -I.

all: src/*.c src/*.h
	gcc ${QC_FLAGS} ${INCS} src/*.c -shared -o _libsolver.so
	rm _libsolver.so
	cp src/*.c ${Q_BUILD_DIR}/src/
	cp src/*.h ${Q_BUILD_DIR}/include/

test_driver: src/*.c src/*.h test/*
	gcc ${INCS} ${C_FLAGS} src/*.c test/test_driver.c ${LIBS} -o test_driver

debug: src/*.c src/*.h test/*
	gcc ${C_FLAGS} -g src/*.c test/test_driver.c ${LIBS} -o test_driver

bench: test_driver
	./test_driver 1000 -b

test: test_driver
	valgrind ./test_driver 100

clean:
	rm -f test_driver
