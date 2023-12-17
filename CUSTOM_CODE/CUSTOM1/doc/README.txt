Specification for the type custom1_t is  stored in ../lua/custom1_terms.lua
lua gen_doth.lua generates inc/custom1.h
This has to be manually included into UTILS/inc/qtypes.h
TODO: Above is ugly. Needs to be avoided. But not sure how to do so.


lua gen_mk_custom1.lua creates ../src/gen_mk_custom1.c which
is included in ../src/mk_custom1.c 

lua gen_pr_custom1.lua creates ../src/gen_pr_custom1.c which
is included in ../src/pr_custom1.c 
