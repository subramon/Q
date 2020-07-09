all : 
	make -C ${Q_SRC_ROOT}/RUNTIME/CUTILS/src/ 
	make -C ${Q_SRC_ROOT}/UTILS/src/ 
	make -C ${Q_SRC_ROOT}/RUNTIME/CMEM/src/ 
	make -C ${Q_SRC_ROOT}/RUNTIME/SCLR/src/ 
	make -C ${Q_SRC_ROOT}/RUNTIME/VCTR/src/ 
	make -C ${Q_SRC_ROOT}/OPERATORS/S_TO_F/lua 
	make -C ${Q_SRC_ROOT}/OPERATORS/F_TO_S/lua 
	make -C ${Q_SRC_ROOT}/OPERATORS/SORT/lua 
	make -C ${Q_SRC_ROOT}/OPERATORS/SORT2/lua 
	make -C ${Q_SRC_ROOT}/OPERATORS/F1F2OPF3/lua 

clean:
	rm -f ${Q_ROOT}/lib/*.so
	#removing the stub file which is required by python-Q wrapper
	rm -f ${Q_SRC_ROOT}/experimental/python_q_wrapper/lua/q_op_stub_file.pyi
	#---
	make -C ${Q_SRC_ROOT}/UTILS/src/  clean
	make -C ${Q_SRC_ROOT}/RUNTIME/CMEM/src/ clean
	make -C ${Q_SRC_ROOT}/RUNTIME/SCLR/src/ clean
	make -C ${Q_SRC_ROOT}/RUNTIME/VCTR/src/ clean
	make -C ${Q_SRC_ROOT}/RUNTIME/CUTILS/src/ clean
	make -C ${Q_SRC_ROOT}/OPERATORS/S_TO_F/lua  clean
	make -C ${Q_SRC_ROOT}/OPERATORS/F_TO_S/lua  clean
	make -C ${Q_SRC_ROOT}/OPERATORS/SORT/lua  clean
	make -C ${Q_SRC_ROOT}/OPERATORS/SORT2/lua  clean
	make -C ${Q_SRC_ROOT}/OPERATORS/F1F2OPF3/lua clean

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
