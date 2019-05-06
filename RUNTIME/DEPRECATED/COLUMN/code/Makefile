doc:
	echo "future to make docs"

test: ./src/libvector_mmap.so 
	(cd test; make all)

./src/libvector_mmap.so  :
	cd src; make all

bin: 
	(cd src; make all)

all: doc test bin
	echo "done"

clean:
	(cd src; make clean)
	(cd test; make clean)
