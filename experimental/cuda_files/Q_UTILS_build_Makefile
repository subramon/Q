DEFAULT_GOAL := all
OUTPUTS = libq_core.so q.h q_core.h
BASE_PATH=$(abspath ../../ )

all: q_core
	echo "Q is built"

clean:
	find ${BASE_PATH} -name "*.o" -o -name "_*" | xargs rm -rf
	rm -f ${Q_ROOT}/lib/*.so
	rm -f ${Q_ROOT}/include/*.h
	rm -f ${Q_BUILD_DIR}/src/*
	rm -f ${Q_BUILD_DIR}/include/*
	make -C ${BASE_PATH}/UTILS/src/  clean
	make -C ${BASE_PATH}/OPERATORS/LOAD_CSV/lua/ clean
	make -C ${BASE_PATH}/OPERATORS/AINB/lua/ clean
	make -C ${BASE_PATH}/OPERATORS/IFXTHENYELSEZ/lua/ clean
	make -C ${BASE_PATH}/OPERATORS/PRINT/lua/ clean
	make -C ${BASE_PATH}/OPERATORS/F1F2OPF3/lua clean
	make -C ${BASE_PATH}/OPERATORS/F1S1OPF2/lua clean
	make -C ${BASE_PATH}/OPERATORS/SORT/lua clean
	make -C ${BASE_PATH}/OPERATORS/IDX_SORT/lua clean
	make -C ${BASE_PATH}/OPERATORS/S_TO_F/lua clean
	make -C ${BASE_PATH}/OPERATORS/F_TO_S/lua clean
	make -C ${BASE_PATH}/OPERATORS/AX_EQUALS_B/ clean
	make -C ${BASE_PATH}/OPERATORS/MM/lua/ clean
	make -C ${BASE_PATH}/OPERATORS/APPROX/QUANTILE/lua  clean
	make -C ${BASE_PATH}/OPERATORS/APPROX/FREQUENT  clean
	make -C ${BASE_PATH}/OPERATORS/PCA/src clean
	make -C ${BASE_PATH}/OPERATORS/DROP_NULLS/lua clean
	make -C ${BASE_PATH}/OPERATORS/WHERE/lua clean
	make -C ${BASE_PATH}/OPERATORS/SUMBY/lua clean

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

all: q_core
	cd ${BASE_PATH}

uninstall:
	rm -rf /usr/local/share/lua/5.1/Q;\
	rm -f /usr/lib/libq_core.so;\
	echo "Q uninstalled"


q_core: q_basic q_operators
	cd ${BASE_PATH}/UTILS/lua/
	lua copy_generated_files.lua 
	luajit mk_so.lua

q_basic: utils load_csv print column
	luajit mk_so.lua /tmp/

column:
	cd ${BASE_PATH}/RUNTIME/src;
	make -C ${BASE_PATH}/RUNTIME/src/

utils:
	make -C ${BASE_PATH}/UTILS/src/ 

drop_nulls:
	make -C ${BASE_PATH}/OPERATORS/DROP_NULLS/lua/

ifxthenyelsez:
	make -C ${BASE_PATH}/OPERATORS/IFXTHENYELSEZ/lua/

ainb:
	make -C ${BASE_PATH}/OPERATORS/AINB/lua/

where:
	make -C ${BASE_PATH}/OPERATORS/WHERE/lua/

sumby:
	make -C ${BASE_PATH}/OPERATORS/SUMBY/lua/

load_csv:
	make -C ${BASE_PATH}/OPERATORS/LOAD_CSV/lua/

print:
	make -C ${BASE_PATH}/OPERATORS/PRINT/lua/

f1f2opf3: q_basic
	make -C ${BASE_PATH}/OPERATORS/F1F2OPF3/lua all
# 	make -C ${BASE_PATH}/OPERATORS/F1F2OPF3/lua all_for_dc

f1s1opf2: q_basic
	make -C ${BASE_PATH}/OPERATORS/F1S1OPF2/lua

sort: q_basic
	make -C ${BASE_PATH}/OPERATORS/SORT/lua

idx_sort: q_basic
	make -C ${BASE_PATH}/OPERATORS/IDX_SORT/lua

s_to_f: q_basic
	make -C ${BASE_PATH}/OPERATORS/S_TO_F/lua

f_to_s: q_basic
	make -C ${BASE_PATH}/OPERATORS/F_TO_S/lua

ax_equals_b: q_basic
	make -C ${BASE_PATH}/OPERATORS/AX_EQUALS_B/

approx_quantile: q_basic
	make -C ${BASE_PATH}/OPERATORS/APPROX/QUANTILE/lua

approx_frequent: q_basic
	make -C ${BASE_PATH}/OPERATORS/APPROX/FREQUENT

mv_mul: q_basic
	make -C ${BASE_PATH}/OPERATORS/MM/lua/

corrm: q_basic
	make -C ${BASE_PATH}/OPERATORS/PCA/src/

# CUDA: Currently focus is on vvadd (f1f2opf3)
q_operators: f1f2opf3
	echo "all done for operators"

