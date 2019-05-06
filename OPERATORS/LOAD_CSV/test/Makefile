CC = gcc
DBG_FLAGS = 
DBG_FLAGS = -g

OPT_FLAGS = -O4
OPT_FLAGS = 
FLAGS= $(OPT_FLAGS) $(DBG_FLAGS) -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic
LINK_FLAGS = -fPIC -shared

INCS= -I../inc \
	-I../gen_inc \
	-I../../../UTILS/inc \
	-I../../../UTILS/gen_inc

<<<<<<< HEAD
all : test_load_csv_fast 
=======
all : test_load_csv_fast  \
	load_csv_fast.so \
	stress_test_load_csv_fast 

>>>>>>> dev
%.o: %.c $(DEPS)
	$(CC) $(INCS) $(FLAGS) -c -o $@ $< -I

SRCS = ../src/load_csv_fast.c \
       test_load_csv_fast.c  \
       ../../../UTILS/src/rand_file_name.c \
       ../../../UTILS/src/get_file_size.c \
       ../../../UTILS/src/trim.c \
       ../../../UTILS/src/file_exists.c \
       ../../../UTILS/src/mmap.c \
       ../../../UTILS/src/is_valid_chars_for_num.c \
       ../src/get_cell.c \
       ../gen_src/_txt_to_I1.c \
       ../gen_src/_txt_to_I2.c \
       ../gen_src/_txt_to_I4.c \
       ../gen_src/_txt_to_I8.c \
       ../gen_src/_txt_to_F4.c \
       ../gen_src/_txt_to_F8.c \

test_load_csv_fast : test_load_csv_fast.c ../src/load_csv_fast.c
<<<<<<< HEAD
	$(CC) $(SRCS) $(INCS) $(FLAGS) -o test_load_csv_fast
=======
	$(CC) $(CSRCS) $(INCS) $(FLAGS) -o test_load_csv_fast

stress_test_load_csv_fast : stress_test_load_csv_fast.c ../src/load_csv_fast.c
	$(CC) stress_test_load_csv_fast.c $(CSRCS3) $(INCS) $(FLAGS) -o stress_test_load_csv_fast

load_csv_fast.so : ../src/load_csv_fast.c
	$(CC) $(CSRCS3) $(INCS) $(FLAGS) -o load_csv_fast.so $(LINK_FLAGS)
	  	
>>>>>>> dev
	  	
	  	

clean:
	rm -f *.o 
	rm -f test_load_csv_fast
	rm -f ../src/*.o
