#!/bin/bash
# find $Q_SRC_ROOT -name "*.lua" -and -not -name "test_*.lua" -and -not -path "./TEST_RUNNER/*" | while read line
let RET=0
# find $Q_SRC_ROOT -name "*.lua" \
#   -and -not -path "./TEST_RUNNER/*" -and -not -path "./experimental/*" \
#   -and -not -path "*/*DEPRECATED*/*" | 
while read line
do
  # echo "$line"
  cat "$line" | awk -F'--' '{print $1}' | grep "os.exit" &>/dev/null
  if [[ $? -ne 0 ]]
  then
    let RET=1
    echo "failed: $line"
  else
    echo "success: $line"
  fi
done < <(find $Q_SRC_ROOT -name "*.lua" \
  -and -not -path "./TEST_RUNNER/*" -and -not -path "./experimental/*" \
  -and -not -path "*/*DEPRECATED*/*")
exit $RET
