%{
#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>
#include <string.h>
#include <inttypes.h>
#include <stdlib.h>
#include "parse_consts.h"
#include "qtypes.h"
#include "q_constants.h"
#include "macros.h"
#include "auxil.h"
#include "extract_S.h"

#define mcr_chk_op_f_to_s(x) { \
    if ( !chk_op_f_to_s(x, g_err) ) {  \
      WHEREAMI; return -1;  \
    } \
}
#define mcr_chk_add_tbl_op(x) { \
    if ( !chk_add_tbl_op(x, g_err) ) {  \
      WHEREAMI; return -1;  \
    } \
}
#define mcr_chk_add_fld_op(x) { \
    if ( !chk_add_fld_op(x, g_err) ) {  \
      WHEREAMI; return -1;  \
    } \
}
#define mcr_chk_tbl_name(x) { \
    if ( !chk_tbl_name(x, g_err) ) {  \
      WHEREAMI; return -1;  \
    } \
}
#define mcr_chk_fld_prop(x) { \
    if ( !chk_fld_prop(x) ) {  \
      sprintf(g_err, "Invalid Field Property = [%s]\n",  x);  \
      WHEREAMI; return -1;  \
    } \
}


#define mcr_chk_nR(x) {  \
  { \
    int64_t num_rows; \
    g_status  = stoI8(str_num_rows, &num_rows); \
    if ( ( g_status < 0 ) || ( num_rows <= 0 ) ) { \
      sprintf(g_err, "Invalid Number of Rows = [%s]\n",  str_num_rows); \
      WHEREAMI; return -1; \
    } \
    } \
}

int g_status;
char g_strings[MAX_NUM_FLDS_IN_LIST][MAX_LEN_FLD_NAME+1];
char datafile[MAX_LEN_FILE_NAME+1];
char metadatafile[MAX_LEN_FILE_NAME+1];

extern char *g_op  ; // [MAX_LEN_PARSED_JSON+1];
extern char *g_in  ; // [MAX_LEN_Q_COMMAND+1];
extern char *g_buf  ; // [MAX_LEN_PARSED_JSON+1];
extern char *g_val ; // [MAX_LEN_Q_VALUE+1];
extern char *g_err ; // [MAX_LEN_Q_ERROR+1];
extern char *g_args; // [MAX_LEN_Q_ARGS+1]; 

TBLTYPE g_tbl;

extern void
zero_tbltype(
  TBLTYPE *ptr_X
  );

void
zero_tbltype(
  TBLTYPE *ptr_X
  )
  {
  ptr_X->where.RestrictionType = 0;
  for ( int i = 0; i < MAX_LEN_TBL_NAME+1; i++ ) {
    ptr_X->tbl[i] = '\0';
    ptr_X->where.cfld[i] = '\0';
  }
  }


#define YYDEBUG 1
/* Define the macro YYDEBUG to a nonzero value when you compile the parser.
This is compliant with POSIX Yacc. You could use ‘-DYYDEBUG=1’ as a 
compiler option or you could put ‘#define YYDEBUG 1’ in the prologue 
of the grammar file (see The Prologue). 
*/

// #include <cstdio>
// #include <iostream>
// using namespace std;

// stuff from flex that bison needs to know about:
// extern "C" int yylex();
// extern "C" int yyparse();
// extern "C" FILE *yyin;
extern int  yylex();
extern int  yyparse();
extern FILE *yyin;
extern int yyerror(const char *s);

%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype":
%union {
        char *str_int;
        char *str_fp;
        char *str_str;
        char *str_vrb;
        char *str_arg;
        char *str_kw;
        char *str_prp;
}


// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <str_int> INT
%token <str_fp>  FP
%token <str_str> STRING
%token <str_vrb> VERB
%token <str_arg> ARGS
%token <str_kw> KEYWORD
%token <str_prp> PROPERTY
%token <tbl> TBL
%token VBAR
%token MINUS
%token PLUS
%token DOT
%token QMARK
%token COLON
%token EQUALS
%token COMMA
%token LT
%token GT
%token ASTERISK
%token POUND

/* Tokens containins multiple characters */
%token NOOP
%token LEQ
%token GEQ
%token ASSIGN
%token ADDTO
%token MOVE
%token GEQANDLEQ
%token GTANDLT
%token LEQORGEQ
%token LTORGT

%token OPEN_SQUARE
%token CLOSE_SQUARE

%token OPEN_ROUND
%token CLOSE_ROUND

%%

command: QMARK {
    strcat(g_op, "{ \n"); 
    strcat(g_op, "  \"verb\" : \"show_tables\" \n"); 
    strcat(g_op, "} \n"); 
         }
| VERB {
    char *op = $1; op += 3; // Jump over OP=
    if ( strcasecmp(op, "NONE") !=  0 ) { 
      sprintf(g_err, "Expected [OP=NONE], got %s \n", $1);
      WHEREAMI; return -1;
    }
    strcat(g_op, "{\n  \"verb\" : \"noop\"\n} \n");
    free($1);
}
| POUND STRING {
    char *tbl_name = $2;
    mcr_chk_tbl_name(tbl_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"tbl_meta\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"property\" : \"NumRows\" \n");
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free($2);
      }
| ASTERISK STRING {
    char *tbl_name = $2;
    mcr_chk_tbl_name(tbl_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"tbl_meta\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"property\" : \"Fields\" \n");
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free($2);
      }
| QMARK STRING {
    char *tbl_name = $2;
    mcr_chk_tbl_name(tbl_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"tbl_meta\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    strcat(g_op, "  \"property\" : \"Exists\" \n");
    strcat(g_op, "} \n");
    free($2);
      }
| QMARK STRING  ASTERISK {
    char *tbl_name = $2;
    mcr_chk_tbl_name(tbl_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"tbl_meta\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    strcat(g_op, "  \"property\" : \"All\" \n");
    strcat(g_op, "} \n");
    free($2);
      }
| QMARK STRING  PROPERTY {
    char *tbl_name = $2;
    char *tbl_prop = $3; tbl_prop += 5; /* jump over PROP= */
    mcr_chk_tbl_name(tbl_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"tbl_meta\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    /* note the underscore below */
    sprintf(g_buf, "  \"property\" : \"%s\" \n", tbl_prop);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($2);
    free_if_non_null($3);
      }
| QMARK STRING DOT STRING {
    char *tbl_name = $2;
    char *fld_name = $4;
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(fld_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"fld_meta\", \n");
    strcat(g_op, "  \"property\" : \"Exists\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"fld\" : \"%s\" \n", fld_name);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($2);
    free_if_non_null($4);
      }
| QMARK STRING  DOT STRING ASTERISK {
    char *tbl_name = $2;
    char *fld_name = $4;
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(fld_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"fld_meta\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"fld\" : \"%s\", \n", fld_name);
    strcat(g_op, g_buf);
    strcat(g_op, "  \"property\" : \"All\" \n");
    strcat(g_op, "} \n");
    free_if_non_null($2);
    free_if_non_null($4);
      }
| QMARK STRING DOT STRING PROPERTY {
    char *tbl_name = $2;
    char *fld_name = $4;
    char *fld_prop = $5; fld_prop += 5; /* jump over PROP= */
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(fld_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"fld_meta\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"fld\" : \"%s\", \n", fld_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"property\" : \"%s\" \n", fld_prop);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($2);
    free_if_non_null($4);
    free_if_non_null($5);
      }
| PLUS STRING DOT STRING PROPERTY PROPERTY_VAL {
    char *tbl_name = $2;
    char *fld_name = $4;
    char *fld_prop = $5; fld_prop += 5;
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(fld_name);
    mcr_chk_fld_prop(fld_prop);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"set_meta\", \n");
    strcat(g_op, "  \"action\" : \"set\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"fld\" : \"%s\", \n", fld_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"property\" : \"%s\", \n", fld_prop);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"value\" : \"%s\" \n", g_val);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($2);
    free_if_non_null($4);
    free_if_non_null($5);
      }
| MINUS STRING DOT STRING PROPERTY {
    char *tbl_name = $2;
    char *fld_name = $4;
    char *fld_prop = $5;  fld_prop += 5;
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(fld_name);
    mcr_chk_fld_prop(fld_prop);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"set_meta\", \n");
    strcat(g_op, "  \"action\" : \"unset\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"fld\" : \"%s\", \n", fld_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"property\" : \"%s\" \n", fld_prop);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($2);
    free_if_non_null($4);
    free_if_non_null($5);
      }
| STRING ASSIGN VERB ARGS {
  char *tbl_name = $1;
  char *op   = $3; op   += 3; // Jump over OP=
  char *args = $4; args += 5; // Jump over ARGS=
  mcr_chk_tbl_name(tbl_name);
  mcr_chk_add_tbl_op(op);
  strcat(g_op, "{ \n");
  strcat(g_op, "  \"verb\" : \"add_tbl\", \n");
  sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
  strcat(g_op, g_buf);
  sprintf(g_buf, "  \"ARGS\" : %s \n", args);
  strcat(g_op, g_buf);
  strcat(g_op, "} \n");
  free_if_non_null($1);
  free_if_non_null($3);
  free_if_non_null($4);

}
| MINUS STRING {
    char *tbl_name = $2;
    mcr_chk_tbl_name(tbl_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"del_tbl\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\" \n", tbl_name);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($2);
      }
;
| MINUS STRING DOT STRING {
    char *tbl_name = $2;
    char *fld_name = $4;
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(fld_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"del_fld\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"fld\" : \"%s\" \n", fld_name);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($2);
    free_if_non_null($4);
      }
| STRING DOT STRING ASSIGN VERB ARGS {
    
    char *tbl_name = $1;
    char *fld_name = $3;
    char *op       = $5; op   += 3; // jump over OP=
    char *args     = $6; args += 5; // jump over ARGS=
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(fld_name);

    strcat(g_op, "{ \n");
    if ( ( strcasecmp(op, "LoadCSV") == 0 )  ||
         ( strcasecmp(op, "LoadBin") == 0 ) ) {
      strcat(g_op, "  \"verb\" : \"add_fld\", \n");
    }
    else if ( ( strcasecmp(op, "Constant") == 0 )  ||
              ( strcasecmp(op, "Sequence") == 0 )  ||
              ( strcasecmp(op, "Period"  ) == 0 )  ||
              ( strcasecmp(op, "Random"  ) == 0 ) ) {
      strcat(g_op, "  \"verb\" : \"s_to_f\", \n");
    }
    else {
    strcpy(g_err, "Valid values for OP are as follows. ");
    strcat(g_err, "LoadCSV, LoadBin, ");
    strcat(g_err, "Constant, Sequence, Period, Random");
    strcat(g_err, "Got this instead --> ");
    strncat(g_err, op, 32);
    }

    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"fld\" : \"%s\", \n", fld_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"OP\" : \"%s\", \n", op);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"ARGS\" : %s \n", args);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($1);
    free_if_non_null($3);
    free_if_non_null($5);
    free_if_non_null($6);
      }
| STRING OPEN_ROUND STRING ASSIGN VERB STRING CLOSE_ROUND XARGS {
  /* f1opf2 */
    
    char *tbl_name = $1;
    char *f1_name  = $3;
    char *op       = $5; op   += 3; // jump over OP=
    char *f2_name  = $6;
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(f1_name);
    mcr_chk_tbl_name(f2_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"f1opf2\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"f1\" : \"%s\", \n", f1_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"f2\" : \"%s\", \n", f2_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"OP\" : \"%s\"", op);
    strcat(g_op, g_buf);
    if ( *g_args != '\0' ) { 
      strcat(g_op, ", \n");
      sprintf(g_buf, "  \"ARGS\" : %s \n", g_args);
      strcat(g_op, g_buf);
      for ( int i = 0; i < MAX_LEN_Q_ARGS+1; i++ ) { g_args[i] = '\0'; }
    }
    else {
      strcat(g_op, " \n");
    }

    strcat(g_op, "} \n");
    free_if_non_null($1);
    free_if_non_null($3);
    free_if_non_null($5);
    free_if_non_null($6);
      }
| VERB STRING DOT STRING XARGS {

    char *op = $1; op += 3; // jump over OP=
    char *tbl_name = $2;
    char *fld_name = $4;
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(fld_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"f_to_s\", \n");
    mcr_chk_op_f_to_s(op)
    if  ( *g_args != '\0' ) { 
      if ( ( strcmp(op, "ApproxNDV") == 0 ) || 
           ( strcmp(op, "Print")     == 0 ) ||
           ( strcmp(op, "ValAtIdx")  == 0 ) ) {
        /* all is well */
      }
      else {
        WHEREAMI; return -1; 
      }
      sprintf(g_buf, "  \"ARGS\" : %s, \n", g_args);
      strcat(g_op, g_buf);
      for ( int i = 0; i < MAX_LEN_Q_ARGS+1; i++ ) { g_args[i] = '\0'; }
    }
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"fld\" : \"%s\", \n", fld_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"OP\" : \"%s\" \n", op);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($1);
    free_if_non_null($2);
    free_if_non_null($4);
      }
| VERB CTBL DOT STRING XARGS {

    char *op = $1; op += 3; // jump over OP=
    char *fld_name = $4;
    char *tbl_name = g_tbl.tbl;
    char *cfld_name = g_tbl.where.cfld;
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(fld_name);

    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"f_to_s\", \n");
    if  ( *g_args != '\0' ) { 
      if ( ( strcmp(op, "ApproxNDV") == 0 ) || 
           ( strcmp(op, "Print") == 0 ) || 
           ( strcmp(op, "ValAtIdx") == 0 ) ) {
        /* all is well */
      }
      else {
        WHEREAMI; return -1; 
      }
      sprintf(g_buf, "  \"ARGS\" : %s \n", g_args);
      strcat(g_op, g_buf);
      for ( int i = 0; i < MAX_LEN_Q_ARGS+1; i++ ) { g_args[i] = '\0'; }
    }
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);

    strcat(g_op, "  \"Restriction\" : { \n");
    switch ( g_tbl.where.RestrictionType ) { 
    case RESTRICT_CFLD : 
    strcat(g_op, "  \"RestrictionType\" : \"BooleanField\", \n");
    sprintf(g_buf, "  \"BooleanField\" : \"%s\" \n", cfld_name);
    strcat(g_op, g_buf);
    break;
    case RESTRICT_RANGE : 
    strcat(g_op, "  \"RestrictionType\" : \"Range\", \n");
    sprintf(g_buf, "  \"LB\" : \"%" PRId64" \", \n", g_tbl.where.lb);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"UB\" : \"%" PRId64 "\" \n", g_tbl.where.ub);
    strcat(g_op, g_buf);
  
    break;
    case RESTRICT_RANGE_SET : 
    printf(" TODO: hello 3 \n"); WHEREAMI; return -1; 
    break;
    default :
    WHEREAMI; return -1; 
    break;
    }
    strcat(g_op, "  }, \n");

    sprintf(g_buf, "  \"fld\" : \"%s\", \n", fld_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"OP\" : \"%s\" \n", op);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($1);
    free_if_non_null($4);
      }
| STRING ADDTO STRING {
    char *tbl_dst_name = $1;
    char *tbl_src_name = $3;
    mcr_chk_tbl_name(tbl_dst_name);
    mcr_chk_tbl_name(tbl_src_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"app_tbl\", \n");
    sprintf(g_buf, "  \"tbl_dst\" : \"%s\", \n", tbl_dst_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"tbl_src\" : \"%s\" \n", tbl_src_name);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($1);
    free_if_non_null($3);
      }
| STRING ASSIGN STRING {
    char *tbl_dst_name = $1;
    char *tbl_src_name = $3;
    mcr_chk_tbl_name(tbl_dst_name);
    mcr_chk_tbl_name(tbl_src_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"copy_tbl\", \n");
    sprintf(g_buf, "  \"tbl_dst\" : \"%s\", \n", tbl_dst_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"tbl_src\" : \"%s\" \n", tbl_src_name);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($1);
    free_if_non_null($3);
      }
| STRING MOVE STRING {
    char *tbl_dst_name = $1;
    char *tbl_src_name = $3;
    mcr_chk_tbl_name(tbl_dst_name);
    mcr_chk_tbl_name(tbl_src_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"rename_tbl\", \n");
    sprintf(g_buf, "  \"tbl_dst\" : \"%s\", \n", tbl_dst_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"tbl_src\" : \"%s\" \n", tbl_src_name);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($1);
    free_if_non_null($3);
      }
| STRING DOT  STRING ASSIGN STRING DOT STRING {
    char *tbl_dst_name = $1;
    char *fld_dst_name = $3;
    char *tbl_src_name = $5;
    char *fld_src_name = $7;
    mcr_chk_tbl_name(tbl_dst_name);
    mcr_chk_tbl_name(fld_dst_name);
    mcr_chk_tbl_name(tbl_src_name);
    mcr_chk_tbl_name(fld_src_name);
    strcat(g_op, "{ \n");
    if ( strcmp(tbl_dst_name, tbl_src_name) == 0 ) { 
      strcat(g_op, "  \"verb\" : \"dup_fld\", \n");
    }
    else {
      strcat(g_op, "  \"verb\" : \"copy_fld\", \n");
    }
    sprintf(g_buf, "  \"tbl_dst\" : \"%s\", \n", tbl_dst_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"fld_dst\" : \"%s\", \n", fld_dst_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"tbl_src\" : \"%s\", \n", tbl_src_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"fld_src\" : \"%s\" \n",  fld_src_name);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
      free($1);
      free($3);
      free($5);
      free($7);
      }
| STRING DOT  STRING MOVE STRING DOT STRING {
    char *tbl_dst_name = $1;
    char *fld_dst_name = $3;
    char *tbl_src_name = $5;
    char *fld_src_name = $7;
    mcr_chk_tbl_name(tbl_dst_name);
    mcr_chk_tbl_name(fld_dst_name);
    mcr_chk_tbl_name(tbl_src_name);
    mcr_chk_tbl_name(fld_src_name);

    strcat(g_op, "{\n");
    if ( strcmp(tbl_dst_name, tbl_src_name) == 0 ) { 
      strcat(g_op, "  \"verb\" : \"rename_fld\", \n");
    }
    else {
      strcat(g_op, "  \"verb\" : \"mv_fld\", \n");
    }
    sprintf(g_buf, "  \"tbl_dst\" : \"%s\", \n", tbl_dst_name); 
    strcat(g_op, g_buf);

    sprintf(g_buf, "  \"fld_dst\" : \"%s\", \n", fld_dst_name);
    strcat(g_op, g_buf);

    sprintf(g_buf, "  \"tbl_src\" : \"%s\", \n", tbl_src_name);
    strcat(g_op, g_buf);

    sprintf(g_buf, "  \"fld_src\" : \"%s\" \n",  fld_src_name);
    strcat(g_op, g_buf);

    strcat(g_op, "}\n");
    free($1);
    free($3);
    free($5);
    free($7);
  }
;
CTBL : 
     STRING VBAR OPEN_ROUND STRING CLOSE_ROUND
{
  char *tbl_name = $1;
  char *cfld_name = $4;
  mcr_chk_tbl_name(tbl_name);
  mcr_chk_tbl_name(cfld_name);
  // zero_tbl(&g_tbl);
  strcpy(g_tbl.tbl, tbl_name);
  strcpy(g_tbl.where.cfld, cfld_name);
  g_tbl.where.RestrictionType = RESTRICT_CFLD;
} 
| STRING VBAR OPEN_ROUND INT INT CLOSE_ROUND
{
  int status = 0;
  int64_t lb, ub;
  char *tbl_name = $1;
  char *str_lb   = $4;
  char *str_ub   = $5;
  mcr_chk_tbl_name(tbl_name);
  status = stoI8(str_lb, &lb); 
  if ( status < 0 ) { 
    strcpy(g_err, "ERROR: lower bound not an integer. Check ");
    strncat(g_err, str_lb, 32);
    WHEREAMI; return -1;
  }
  status = stoI8(str_ub, &ub); 
  if ( status < 0 ) { 
    strcpy(g_err, "ERROR: upper bound not an integer. Check ");
    strncat(g_err, str_ub, 32);
    WHEREAMI; return -1;
  }
  if ( lb < 0 ) { 
    sprintf(g_err, "ERROR: Lower bound [%" PRId64 "] is less than 0.", lb);
    WHEREAMI; return -1; 
  }
  if ( lb >= ub ) { 
    sprintf(g_err, 
    "ERROR: Lower bound [%" PRId64 " >= upper bound [%" PRId64 ".", lb, ub);
    WHEREAMI; return -1; 
  }
  // zero_tbl(&g_tbl);
  strcpy(g_tbl.tbl, tbl_name);
  g_tbl.where.lb = lb;
  g_tbl.where.ub = ub;
  g_tbl.where.RestrictionType = RESTRICT_RANGE;
} 
| STRING VBAR OPEN_ROUND STRING STRING STRING CLOSE_ROUND XARGS
{
  char *tbl_name = $1;
  char *ctbl   = $4;
  char *lbfld = $5;
  char *ubfld = $6;
  mcr_chk_tbl_name(tbl_name);
  mcr_chk_tbl_name(ctbl);
  mcr_chk_tbl_name(lbfld);
  mcr_chk_tbl_name(ubfld);
  // zero_tbl(&g_tbl);
  strcpy(g_tbl.tbl, tbl_name);
  strcpy(g_tbl.where.ctbl, ctbl);
  strcpy(g_tbl.where.lbfld, lbfld);
  strcpy(g_tbl.where.ubfld, ubfld);
  g_tbl.where.RestrictionType = RESTRICT_RANGE_SET;
} 
;
XARGS :
{
  for ( int i = 0; i < MAX_LEN_Q_ARGS+1; i++ ) { g_args[i] = '\0'; }
}
|
ARGS
{
  int len = strlen($1);
  if ( ( len <= 5 ) || ( len >= MAX_LEN_Q_ARGS+5 ) ) { 
    sprintf(g_err, "Arguments are too long. Fishy...");
    WHEREAMI; return -1;
  }
  strcpy(g_args, $1+5); 
}
;
PROPERTY_VAL : INT {
  int len = 0;
  for ( char *cptr = $1; *cptr != '\0'; cptr++, len++ ) { 
    if ( len >= MAX_LEN_Q_VALUE ) {
      strcpy(g_err, "Value provided is too long. First 32 chars are");
      strncat(g_err, $1, 32);
      WHEREAMI;
      return -1;
    }
    g_val[len] = *cptr;
  }
}
| STRING {
  int len = 0;
  for ( char *cptr = $1; *cptr != '\0'; cptr++, len++ ) { 
    if ( len >= MAX_LEN_Q_VALUE ) {
      strcpy(g_err, "Value provided is too long. First 32 chars are");
      strncat(g_err, $1, 32);
      WHEREAMI;
      return -1;
    }
    g_val[len] = *cptr;
  }
};



%%
int yyerror(
    const char *s
    ) 
{
  sprintf(g_err, "EEK, parse error!  Message: [%s]\n", s);
  WHEREAMI;
  return -1;
}
