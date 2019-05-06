# ASSIGNMENT:2 CSV_LOAD
#Compile + run instructions:

#1) Change the directory to Q/experimental/csv_load

#2) Compile the C code and create the QFunc.so file, the command is:
gcc -fPIC -shared -o QCFunc.so QCFunc.c

#3) In QCFunct.lua file Set the Path where to create the bin files:
#e.g.: local binfilepath = "/home/pranav/q/git/srinath/Q/experimental/CSV_LOAD/"

#4) In main.lua file set the path of csv file which u will give as the input file:
#e.g.: local csv_file_path_name = "./csv_inputfile1.csv"  

#5) Adjust metadata in main.lua according to the csv file you are reading 

#6) Then run the main.lua file, the command is:
luajit main.lua






############## REMAINING Things ############
# - fix size string 
# - Dictionary for varchar 
# - NULL value handing
# - Metadta's ignore column .. i.e. setting the name as "" (empty string) in metadata 
# - Storing generated file in the directory specified by global variable
# - custom datatype (ts example given in csv_load.pdf)
#
#
#
