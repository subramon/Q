# $Id: Makefile,v 1.36 2009/09/21 17:02:44 mascarenhas Exp $

CONFIG= ./config
G=./GENFILES/

include $(CONFIG)

SRCS=  \
	$(G)/pr_fld_I1.c  \
	$(G)/pr_fld_I2.c  \
	$(G)/pr_fld_I4.c  \
	$(G)/pr_fld_I8.c  \
	$(G)/pr_fld_F4.c  \
	$(G)/pr_fld_F8.c  \



OBJS= \
	$(G)/pr_fld_I1.o  \
	$(G)/pr_fld_I2.o  \
	$(G)/pr_fld_I4.o  \
	$(G)/pr_fld_I8.o  \
	$(G)/pr_fld_F4.o  \
	$(G)/pr_fld_F8.o  \



lib: primitives.so

all : lib

primitives.so: $(OBJS)
	$(CC) $(CFLAGS) $(LIB_OPTION) -o primitives.so $(OBJS) 

clean:
	rm -f $(lib)  $(OBJS)
