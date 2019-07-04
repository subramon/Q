DEFAULT_GOAL := all
# TODO P2 : Replace /tmp/q/ with Q_BUILD_DIR
OUTPUTS = /tmp/q/libq_core.so q.h q_core.h
Q_SRC_ROOT=$(abspath ../../ )

# Default build is static
all: static

#static & dynamic targets sets the "BUILD_TYPE" target specific variable
#static build -> all and dynamic build-> all_for_dc
static: BUILD_TYPE="all"

dynamic: BUILD_TYPE="all_for_dc"

static: /tmp/q/libq_core.so
	cd ${Q_SRC_ROOT}
	echo "Q statically compiled"

# Why does dynamic depend on q_core and not on q_basic?
dynamic: /tmp/q/libq_core.so
	cd ${Q_SRC_ROOT}
	echo "Q dynamically compiled"

clean:
	rm -f _*
	find ${Q_SRC_ROOT} -name "*.o" -o -name "_*" | xargs rm -rf
	rm -f ${Q_ROOT}/lib/*.so
	rm -f ${Q_ROOT}/include/*.h
	rm -r -f ${Q_BUILD_DIR}/
	mkdir -p ${Q_BUILD_DIR}/
	#removing the stub file which is required by python-Q wrapper
	rm -f ${Q_SRC_ROOT}/experimental/python_q_wrapper/lua/q_op_stub_file.pyi
	#---
	make -C ${Q_SRC_ROOT}/RUNTIME/src/      clean
	make -C ${Q_SRC_ROOT}/RUNTIME/DNN/src/  clean
	make -C ${Q_SRC_ROOT}/RUNTIME/AGG/src/  clean
	#---
	make -C ${Q_SRC_ROOT}/UTILS/src/  clean
	make -C ${Q_SRC_ROOT}/OPERATORS/LOAD_CSV/lua/ clean
	make -C ${Q_SRC_ROOT}/OPERATORS/PRINT/lua/ clean
	#---
	make -C ${Q_SRC_ROOT}/OPERATORS/HASH/lua/ clean
	make -C ${Q_SRC_ROOT}/OPERATORS/AINB/lua/ clean
	make -C ${Q_SRC_ROOT}/OPERATORS/IFXTHENYELSEZ/lua/ clean
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
	make -C ${Q_SRC_ROOT}/OPERATORS/MDB/lua/ clean

install: uninstall 
	cd ../../;\
	mkdir /usr/local/share/lua/5.1/Q;\
	cp -r ./OPERATORS /usr/local/share/lua/5.1/Q;\
	cp -r ./UTILS /usr/local/share/lua/5.1/Q;\
	cp -r ./RUNTIME /usr/local/share/lua/5.1/Q;\
	cp -r  q_export.lua /usr/local/share/lua/5.1/Q;\
	cp -r  init.lua /usr/local/share/lua/5.1/Q;\
	# TODO P3 FIX THIS, pick library from build target
	cp ${Q_ROOT}/lib/libq_core.so /usr/lib;\
	cp ${Q_ROOT}/include/q_core.h /usr/local/share/lua/5.1/Q


uninstall:
	rm -rf /usr/local/share/lua/5.1/Q;\
	rm -f /usr/lib/libq_core.so;\
	echo "Q uninstalled"

/tmp/q/libq_core.so: _q_basic _vec _dnn _q_operators _agg
	cd ${Q_SRC_ROOT}/UTILS/lua/
	luajit mk_so.lua
	cp /tmp/q/libq_core.so ${Q_ROOT}/lib/

# OLD _q_basic: _utils _load_csv _print _runtime
_q_basic: _utils  _vec _dnn
	luajit mk_so.lua 
	touch _q_basic

_vec: 
	make  -C ${Q_SRC_ROOT}/UTILS/src/
	make  -C ${Q_SRC_ROOT}/OPERATORS/LOAD_CSV/lua/
	make  -C ${Q_SRC_ROOT}/OPERATORS/PRINT/lua/
	make  -C ${Q_SRC_ROOT}/RUNTIME/src/
	touch _vec

_dnn: 
	make  -C ${Q_SRC_ROOT}/UTILS/src/
	make  -C ${Q_SRC_ROOT}/OPERATORS/LOAD_CSV/lua/
	make  -C ${Q_SRC_ROOT}/OPERATORS/PRINT/lua/
	make  -C ${Q_SRC_ROOT}/RUNTIME/src/
	make  -C ${Q_SRC_ROOT}/RUNTIME/DNN/src/
	touch _dnn

_agg: _load_csv _print _utils _vec 
	make  -C ${Q_SRC_ROOT}/RUNTIME/AGG/src/
	touch _agg

# OLD _runtime: _load_csv _print _utils _vec _dnn # _agg
# OLD 	touch _runtime


_utils:
	make  -C ${Q_SRC_ROOT}/UTILS/src/ 
	touch _utils

_load_csv: _utils
	make  -C ${Q_SRC_ROOT}/OPERATORS/LOAD_CSV/lua/
	touch _load_csv

_print: _utils
	make  -C ${Q_SRC_ROOT}/OPERATORS/PRINT/lua/
	touch _print

#-----------------------------------
_approx_quantile: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/APPROX/QUANTILE/lua ${BUILD_TYPE}
	touch _approx_quantile

_approx_frequent: _q_basic _sort
	make  -C ${Q_SRC_ROOT}/OPERATORS/APPROX/FREQUENT ${BUILD_TYPE}
	touch _approx_frequent

_ainb:
	make  -C ${Q_SRC_ROOT}/OPERATORS/AINB/lua/ ${BUILD_TYPE}
	touch _ainb

_ax_equals_b: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/AX_EQUALS_B/
	touch _ax_equals_b

_corrm: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/PCA/src/
	touch _corrm

_count: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/COUNT/lua/ ${BUILD_TYPE}
	touch _count

_drop_nulls: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/DROP_NULLS/lua/ ${BUILD_TYPE}
	touch _drop_nulls

_f_to_s: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/F_TO_S/lua ${BUILD_TYPE}
	touch _f_to_s

_f1opf2f3: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/F1OPF2F3/lua ${BUILD_TYPE}
	touch _f1opf2f3

_f1f2opf3: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/F1F2OPF3/lua ${BUILD_TYPE}
	touch _f1f2opf3

_f1s1opf2: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/F1S1OPF2/lua ${BUILD_TYPE}
	touch _f1s1opf2

_f1s1opf2_val: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/F1S1OPF2_VAL/lua ${BUILD_TYPE}
	touch _f1s1opf2_val

_get: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/GET/lua ${BUILD_TYPE}
	touch _get

_getk: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/GETK/lua/ ${BUILD_TYPE}
	touch _getk

_hash: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/HASH/lua/
	touch _hash

_index: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/INDEX/lua/ ${BUILD_TYPE}
	touch _index

_ifxthenyelsez: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/IFXTHENYELSEZ/lua/ ${BUILD_TYPE}
	touch _ifxthenyelsez

_join: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/JOIN/lua/ ${BUILD_TYPE}
	touch _join

_idx_sort: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/IDX_SORT/lua ${BUILD_TYPE}
	touch _idx_sort

_mv_mul: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/MM/lua/ ${BUILD_TYPE}
	touch _mv_mul

_mdb: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/MDB/lua/ ${BUILD_TYPE}
	touch _mdb

_s_to_f: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/S_TO_F/lua ${BUILD_TYPE}
	touch _s_to_f

_sort: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/SORT/lua ${BUILD_TYPE}
	touch _sort

_sort2: _q_basic
	make  -C ${Q_SRC_ROOT}/OPERATORS/SORT2/lua ${BUILD_TYPE}
	touch _sort2

_sumby:
	make  -C ${Q_SRC_ROOT}/OPERATORS/GROUPBY/lua/ ${BUILD_TYPE}
	touch _sumby

_unique:
	make  -C ${Q_SRC_ROOT}/OPERATORS/UNIQUE/lua/ ${BUILD_TYPE}
	touch _unique

_where:
	make  -C ${Q_SRC_ROOT}/OPERATORS/WHERE/lua/ ${BUILD_TYPE}
	touch _where

# maintain following list in alphabetical order
_q_operators: \
	_ainb \
	_approx_frequent \
	_approx_quantile \
	_ax_equals_b \
	_corrm \
	_count  \
	_drop_nulls \
	_f_to_s \
	_f1f2opf3 \
  	_f1opf2f3 \
	_f1s1opf2 \
	_f1s1opf2_val \
	_get \
	_getk \
	_hash \
	_idx_sort \
	_ifxthenyelsez \
	_index \
	_join \
	_mdb \
	_mv_mul \
	_s_to_f \
	_sort \
	_sort2 \
	_sumby  \
	_unique \
	_where  \

	touch _q_operators 
	echo "all done for operators"
