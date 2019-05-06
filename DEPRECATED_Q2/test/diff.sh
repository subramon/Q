#!/bin/bash
set -e
diff const_fF4.csv _const_fF4.csv
diff const_fF8.csv _const_fF8.csv
diff const_fI1.csv _const_fI1.csv
diff const_fI2.csv _const_fI2.csv
diff const_fI4.csv _const_fI4.csv
diff const_fI8.csv _const_fI8.csv
echo "Successfully Completed $0 in $PWD"
