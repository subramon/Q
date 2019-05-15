DEFAULT_GOAL := all
OUTPUTS = libq_core.so q.h q_core.h
Q_SRC_ROOT=$(abspath ../../ )

# Default build is static
all: static

#static & dynamic targets sets the "BUILD_TYPE" target specific variable
#static build -> all and dynamic build-> all_for_dc
static: BUILD_TYPE="all"

dynamic: BUILD_TYPE="all_for_dc"

static: q_core
	cd ${Q_SRC_ROOT}
	echo "Q statically compiled"

# Why does dynamic depent on q_core and not on q_basic?
dynamic: q_core
	cd ${Q_SRC_ROOT}
	echo "Q dynamically compiled"

clean:
	find ${Q_SRC_ROOT} -name "*.o" -o -name "_*" | xargs rm -rf
	rm -f ${Q_ROOT}/lib/*.so
	rm -f ${Q_ROOT}/include/*.h
	rm -f ${Q_BUILD_DIR}/src/*
	rm -f ${Q_BUILD_DIR}/include/*
	#removing the stub file which is required by python-Q wrapper
	rm -f ${Q_SRC_ROOT}/experimental/python_q_wrapper/lua/q_op_stub_file.pyi
	make -C ${Q_SRC_ROOT}/UTILS/src/  clean
	make -C ${Q_SRC_ROOT}/OPERATORS/LOAD_CSV/lua/ clean
	make -C ${Q_SRC_ROOT}/OPERATORS/HASH/lua/ clean
	make -C ${Q_SRC_ROOT}/OPERATORS/AINB/lua/ clean
	make -C ${Q_SRC_ROOT}/OPERATORS/IFXTHENYELSEZ/lua/ clean
	make -C ${Q_SRC_ROOT}/OPERATORS/PRINT/lua/ clean
	make -C ${Q_SRC_ROOT}/OPERATORS/F1OPF2F3/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/F1F2OPF3/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/F1S1OPF2/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/SORT/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/SORT2/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/GET/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/IDX_SORT/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/S_TO_F/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/F_TO_S/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/AX_EQUALS_B/ clean
	make -C ${Q_SRC_ROOT}/OPERATORS/APPROX/QUANTILE/lua  clean
	make -C ${Q_SRC_ROOT}/OPERATORS/APPROX/FREQUENT  clean
	make -C ${Q_SRC_ROOT}/OPERATORS/PCA/src clean
	make -C ${Q_SRC_ROOT}/OPERATORS/DROP_NULLS/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/WHERE/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/GROUPBY/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/GETK/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/INDEX/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/UNIQUE/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/COUNT/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/JOIN/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/F1S1OPF2_VAL/lua clean
	make -C ${Q_SRC_ROOT}/OPERATORS/MM/lua/ clean

install: uninstall 
	cd ../../;\
	mkdir /usr/local/share/lua/5.1/Q;\
	cp -r ./OPERATORS /usr/local/share/lua/5.1/Q;\
	cp -r ./UTILS /usr/local/share/lua/5.1/Q;\
	cp -r ./RUNTIME /usr/local/share/lua/5.1/Q;\
	cp -r  q_export.lua /usr/local/share/lua/5.1/Q;\
	cp -r  init.lua /usr/local/share/lua/5.1/Q;\
	# FIX THIS, pick library from build target
	cp ${Q_ROOT}/lib/libq_core.so /usr/lib;\
	cp ${Q_ROOT}/include/q_core.h /usr/local/share/lua/5.1/Q


uninstall:
	rm -rf /usr/local/share/lua/5.1/Q;\
	rm -f /usr/lib/libq_core.so;\
	echo "Q uninstalled"


q_core: q_basic q_operators
	cd ${Q_SRC_ROOT}/UTILS/lua/
	lua copy_generated_files.lua 
	luajit mk_so.lua

q_basic: utils load_csv print runtime
	luajit mk_so.lua /tmp/

runtime:
	cd ${Q_SRC_ROOT}/RUNTIME/src;
	make  -C ${Q_SRC_ROOT}/RUNTIME/src/

utils:
	make  -C ${Q_SRC_ROOT}/UTILS/src/ 

drop_nulls:
	make  -C ${Q_SRC_ROOT}/OPERATORS/DROP_NULLS/lua/ ${BUILD_TYPE}

ifxthenyelsez:
	make  -C ${Q_SRC_ROOT}/OPERATORS/IFXTHENYELSEZ/lua/ ${BUILD_TYPE}

ainb:
	make  -C ${Q_SRC_ROOT}/OPERATORS/AINB/lua/ ${BUILD_TYPE}

where:
	make  -C ${Q_SRC_ROOT}/OPERATORS/WHERE/lua/ ${BUILD_TYPE}

sumby:
	make  -C ${Q_SRC_ROOT}/OPERATORS/GROUPBY/lua/ ${BUILD_TYPE}

getk:
	make  -C ${Q_SRC_ROOT}/OPERATORS/GETK/lua/ ${BUILD_TYPE}

index:
	make  -C ${Q_SRC_ROOT}/OPERATORS/INDEX/lua/ ${BUILD_TYPE}

unique:
	make  -C ${Q_SRC_ROOT}/OPERATORS/UNIQUE/lua/ ${BUILD_TYPE}

count:
	make  -C ${Q_SRC_ROOT}/OPERATORS/COUNT/lua/ ${BUILD_TYPE}

join:
	make  -C ${Q_SRC_ROOT}/OPERATORS/JOIN/lua/ ${BUILD_TYPE}

load_csv:
	make  -C ${Q_SRC_ROOT}/OPERATORS/LOAD_CSV/lua/

hash:
	make  -C ${Q_SRC_ROOT}/OPERATORS/HASH/lua/

print:
	make  -C ${Q_SRC_ROOT}/OPERATORS/PRINT/lua/

f1opf2f3: q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/F1OPF2F3/lua ${BUILD_TYPE}

f1f2opf3: q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/F1F2OPF3/lua ${BUILD_TYPE}

f1s1opf2: q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/F1S1OPF2/lua ${BUILD_TYPE}

f1s1opf2_val: q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/F1S1OPF2_VAL/lua ${BUILD_TYPE}

sort: q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/SORT/lua ${BUILD_TYPE}

sort2: q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/SORT2/lua ${BUILD_TYPE}

get: q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/GET/lua ${BUILD_TYPE}

idx_sort: q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/IDX_SORT/lua ${BUILD_TYPE}

s_to_f: q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/S_TO_F/lua ${BUILD_TYPE}

f_to_s: q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/F_TO_S/lua ${BUILD_TYPE}

ax_equals_b: q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/AX_EQUALS_B/

approx_quantile: q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/APPROX/QUANTILE/lua ${BUILD_TYPE}

approx_frequent: q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/APPROX/FREQUENT ${BUILD_TYPE}

mv_mul: q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/MM/lua/ ${BUILD_TYPE}

corrm: q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/PCA/src/

# maintain following list in alphabetical order
q_operators: \
	ainb \
	approx_quantile \
	approx_frequent \
	ax_equals_b \
	corrm \
	f_to_s \
	f1f2opf3 \
  	f1opf2f3 \
	f1s1opf2 \
	f1s1opf2_val \
	get \
	ifxthenyelsez \
	idx_sort \
	sort \
	sort2 \
	s_to_f \
	drop_nulls \
	sumby  \
	index \
	unique \
	count \
	join \
	mv_mul \
	getk \
	hash \
	where 
	echo "all done for operators"


