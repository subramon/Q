## Prepare input step (one time activity)
	- Refer 'Q/RUNTIME/DNN/test/prepare_input.lua'
	- Update the number of samples to appropriate value (variable 'n_samples')
	- Update the network structure assigned to 'npl' (e.g npl = { 128, 64, 32, 8, 4, 2, 1 })
	- Update 'afns' (activation function) and 'dpl' (bias)
	- Run the below command
		$ cd Q/RUNTIME/DNN/test/
		$ luajit prepare_test_input.lua
	This will create the 'dnn_in.txt' in the current directory.
	

## Run DNN code
	- Refer 'Q/RUNTIME/DNN/test/run_dnn_code.lua'
	- batch_size is input to the function run_dnn()
	- Provide the number of samples same as specified in prepare_input.lua
	- Run the below command to get the timings
		$ luajit -e "require 'run_dnn_code'()"
		
		Currently getting segfault, will analyse it
