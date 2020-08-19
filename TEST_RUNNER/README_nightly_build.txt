1. To run static compilation Q run:
$ cd Q/
$ bash daily_q_testrunner_status.sh

2. To run dynamic compilation Q run:
We need to do one change in daily_q_testrunner_status.sh at line 27
from: build_output=$(make static 2>&1)
to:     build_output=$(make dynamic 2>&1)
$ cd Q/
$ bash daily_q_testrunner_status.sh

3. To run stress nighly run:
$ cd Q/
$ bash daily_q_testrunner_stress.sh

4. To run Lua-Luaffi combination:
$ cd Q/
$ bash daily_q_testrunner_luaffi.sh
