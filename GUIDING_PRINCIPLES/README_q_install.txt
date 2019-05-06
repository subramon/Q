q_install.sh:
This script does all the installations(packages, libraries, dependencies) required to run/use Q.

Usage of q_install.sh:
bash q_install.sh <prod|dev|dbg>

Modes:
For now there are 3 modes in which Q can be installed:

Sr.no | Mode name     | Mode usage
---------------------------------------------------------------------------------
1.    | prod 	      | Production mode have just the bare bones of Q to run the Q scripts.
2.    | dev           | Developer mode have everything else: testing, documentation, qli.
3.    | dbg           | Debug mode will be useful for debugging.

TODOs:
1. once penlight dependencies are removed from Q built files, it can be removed from q_required_packages.sh
2. for q_doc_dependencies, execute mk_doc*.sh(for eg: Q/ML/DT/doc/mk_doc*.sh) scripts and copy the pdfs to /tmp/ directory
3. grep for TODOs in current directory
