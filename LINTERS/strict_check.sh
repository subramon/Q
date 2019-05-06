#!/bin/bash
let RET=0
# find $Q_SRC_ROOT -name "test_*.lua" -and -not -path "./TEST_RUNNER/*" | 
while read line
do
  head -n1 "$line" | egrep "^\s*--" &>/dev/null
  if [[ $? -ne 0 ]]
  then
    let RET=1
    echo "failed: $line"
  else
    head -n2 "$line" | tail -n1 | egrep "^\s*require\s+['\"]strict['\"]" &>/dev/null
    if [[ $? -ne 0 ]]
    then
      let RET=1
      echo "failed: $line"
    else
      echo "success: $line"
    fi
  fi
done < <(find $Q_SRC_ROOT -name "test_*.lua" -and -not -path "./TEST_RUNNER/*")
exit $RET
