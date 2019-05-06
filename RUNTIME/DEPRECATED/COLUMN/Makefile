# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

all: doc test bin
	echo "done"

doc:
	echo "future to make docs"

test: bin
	echo ${LUA_INIT}
	$(call check_defined, LUA_INIT, where all package paths are set)
	$(call check_defined, LD_LIBRARY_PATH, where all lib paths are set)
	# $? || exit 1
	(cd code/test; make all)

bin: 
	(cd code/src; make all)

clean:
	(cd code/src; make clean)
	(cd code/test; make clean)
