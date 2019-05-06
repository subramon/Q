#!/bin/bash
echo "----OS EXIT CHECK----"
./no_exit_check.sh &> /dev/null
VAL+=$?
FAIL=`./no_exit_check.sh | grep "failed:" | wc -l`
SUCCESS=`./no_exit_check.sh | grep "success:" | wc -l`
TOTAL=$((FAIL + SUCCESS))
echo "$SUCCESS/$FAIL/$TOTAL (success/failures/total), run no_exit_checK.sh for details"
echo "----REQUIRE STRICT CHECK----"
./strict_check.sh &> /dev/null
VAL+=$?
FAIL=`./strict_check.sh | grep "failed:" | wc -l`
SUCCESS=`./strict_check.sh | grep "success:" | wc -l`
TOTAL=$((FAIL + SUCCESS))
echo "$SUCCESS/$FAIL/$TOTAL (success/failures/total), run strict_checK.sh for details"
exit $VAL
