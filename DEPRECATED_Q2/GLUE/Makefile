T= qglue

CONFIG= ./config
P=../PARSER
A=../AUX
G=../PRIMITIVES/obj/

include $(CONFIG)

SRCS= src/$T.c \
      	$(P)/q2json.c \
	$(A)/extract_S.c  \
	$(A)/auxil.c  \
	$(A)/dbauxil.c  \
	$(A)/mmap.c  \
	$(A)/mk_file.c  \
	$(P)/qgrammar.tab.c  \


OBJS= src/$T.o \
      	$(P)/q2json.o \
	$(A)/extract_S.o  \
	$(A)/auxil.o  \
	$(A)/dbauxil.o  \
	$(A)/mmap.o  \
	$(A)/mk_file.o  \
	$(P)/qgrammar.tab.o  \

VSRCS = $(shell find ../VERBS/ -name \*.c -print)
VOBJS = $(VSRCS:.c=.o)

PSRCS = $(shell find ../PRIMITIVES/src/ -name \*.c -print)
POBJS = $(shell find ../PRIMITIVES/src/ -name \*.c -print | sed s'/src/obj/'g | sed s'/\.c/.o/'g )
# POBJS = $(PSRCS:.c=.o)



#	../VERBS/ADD_FLD/add_fld.o \
#	../VERBS/PR_FLD/pr_fld.o \
#	$(G)/pr_fld_I1.o  \
#	$(G)/pr_fld_I2.o  \
#	$(G)/pr_fld_I4.o  \
#	$(G)/pr_fld_I8.o  \
#	$(G)/pr_fld_F4.o  \
#	$(G)/pr_fld_F8.o  \


lib: qglue.so

all : lib

../PRIMITIVES/obj/%.o : ../PRIMITIVES/src/%.c
	echo "Creating $@ from $< "
	$(CC) -c -o $@ $< $(CFLAGS) $(INCS) $(INCDIR)

.c.o :
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS)

qglue.so: $(OBJS) $(VOBJS) $(POBJS)
	$(CC) $(CFLAGS) $(LIB_OPTION) -o qglue.so \
  	$(OBJS) $(POBJS) $(VOBJS)  -lfl
	cp qglue.so /tmp/

install:
	mkdir -p $(LUA_LIBDIR)
	cp qglue.so $(LUA_LIBDIR)

clean:
	rm -f qglue.so $(OBJS) $(VOBJS) $(POBJS)
