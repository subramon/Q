Required setup for CLion:(Linux) 

1) Link for downloading the tar file for CLion:
https://www.jetbrains.com/clion/download/#section=linux
Refer Screenshot: 1_CLion_Download_Link
Unzip the tar file at desired directory location

2) Follow the steps specified in Install-Linux-tar.txt file present at extracted clion directory

3) To start CLion run the following command from bin/ directory of CLion tar:
Downloads/clion-2018.1.1/bin$ ./clion.sh 
Refer Screenshot: 1_CLion_To_Start_From_Command_Line

4) To add a Lua plugin in CLion:
File-> Settings-> Plugins-> In Search box type Lua -> On right side, It will show up a plugin called 'Lua: Lua language integration for IntelliJ'
-> There is an option(called Install) click on it-> Apply-> Ok
Refer Screenshot: 2_Add_Lua_Plugin
Note: After adding this plugin, all .lua files are recognised and it shows lua icon for all the lua files in the current selected project.
Refer Screenshot: 3_After_Adding_Plugin

5) To select Q as current project in CLion UI:
File-> Open...-> Select the Q repo by browsing to the Q directory 
Refer Screenshot: 3_Select_Q_as_project

6) Set Lua interpreter:
 
I) To set default luajit interpreter for all lua script:
Run-> Edit configurations-> Under Defaults option, select Lua script
Below Lua interpreter option just uncheck 'Use module SDK' checkbox and enter the luajit location(/usr/local/bin/luajit) in textbox.
Click apply-> Click Ok
Refer Screenshots:
4_Run_Configurations_Required
5_Run_Configuration_Option_Window
7_Lua_Details_for_Default_Interpreter

II) To run any particular lua script:
Run-> Edit configurations-> Click on + button and select Lua script option-> 
Fill in the details there:
i) Script name: experimental/luajit_vs_luaffi/luajit_vs_luaffi_independent_test/run_vvadd.lua
ii) Lua Interpreter: 
Uncheck Use module SDK checkbox and enter the luajit location(/usr/local/bin/luajit) in textbox.
iii) Working directory: eg select Q as working directory.
iv) (optinal) Environment variables: set if any required OR By setting environment variables on terminal(source setup -f) then start clion from that terminal.
Click apply-> Click Ok
Refer Screenshots:
4_Run_Configurations_Required
5_Run_Configuration_Option_Window
6_Add_Lua_Interpreter_details
7_Lua_Details_for_Interpreter_Particular_Script

7) To Run lua scripts   : Shift+F10
Refer Screenshot: 8_Run(shift+F10)

8) To Debug lua scripts : Shift+F9
Refer Screenshots: 
9_Debug(shift+F9)
9_debug_step_into_and_inline_debugging_1
9_debug_step_into_and_inline_debugging_2