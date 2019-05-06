%{
#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>
#include <string.h>
#include <inttypes.h>
#include <stdlib.h>
#include "parse_consts.h"
#include "constants.h"
#include "macros.h"
#include "auxil.h"
#include "extract_S.h"

#define mcr_chk_tbl_name(x) { \
    if ( !chk_tbl_name(x) ) {  \
      fprintf(stderr, "Invalid Table Name = [%s]\n",  x);  \
      WHEREAMI; return 1;  \
    } \
}
#define mcr_chk_fld_prop(x) { \
    if ( !chk_fld_prop(x) ) {  \
      fprintf(stderr, "Invalid Field Property = [%s]\n",  x);  \
      WHEREAMI; return 1;  \
    } \
}


#define mcr_chk_nR(x) {  \
  { \
    long long num_rows; \
    g_status  = stoI8(str_num_rows, &num_rows); \
    if ( ( g_status < 0 ) || ( num_rows <= 0 ) ) { \
      fprintf(stderr, "Invalid Number of Rows = [%s]\n",  str_num_rows); \
      WHEREAMI; return 1; \
    } \
    } \
}

int g_status;
char g_strings[MAX_NUM_FLDS_IN_LIST][MAX_LEN_FLD_NAME+1];
char datafile[MAX_LEN_FILE_NAME+1];
char metadatafile[MAX_LEN_FILE_NAME+1];

extern char *g_op  ; // [MAX_LEN_PARSED_JSON+1];
extern char *g_in  ; // [MAX_LEN_Q_COMMAND+1];
extern char *g_buf ; // [MAX_LEN_PARSED_JSON+1];


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
        char *str_opt;
        char *str_kw;
        char *str_prp;
        char *str_tof; /* tof = Table Or Field */
}


// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <str_int> INT
%token <str_fp>  FP
%token <str_str> STRING
%token <str_vrb> VERB
%token <str_opt> OPTIONS
%token <str_kw> KEYWORD
%token <str_prp> PROPERTY
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

%token OPEN_CURLY
%token CLOSE_CURLY

%token OPEN_SQUARE
%token CLOSE_SQUARE

%token OPEN_ROUND
%token CLOSE_ROUND

%token ADD_TBL
%token ADD_FLD
%token DEL_TBL
%token DEL_FLD

%%

command: QMARK {
    strcat(g_op, "{ \n"); 
    strcat(g_op, "  \"verb\" : \"show_tables\" \n"); 
    strcat(g_op, "} \n"); 
         }
| VERB {
    char *op = $1; op += 3; // Jump over OP=
    if ( strcasecmp(op, "NONE") !=  0 ) { 
      fprintf(stderr, "Expected [OP=NONE], got %s \n", $1);
      WHEREAMI; return 1;
    }
    strcat(g_op, "{\n  \"verb\" : \"noop\"\n} \n");
    free($1);
}
| QMARK STRING {
    int status = 0;
    char *tbl_name = $2;
    mcr_chk_tbl_name(tbl_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"is_tbl\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\" \n", tbl_name);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free($2);
      }
| QMARK STRING  ASTERISK {
    int status = 0;
    char *tbl_name = $2;
    mcr_chk_tbl_name(tbl_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"tbl_meta\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, "  \"property\" : \"\" \n");
    strcat(g_op, "} \n");
    free($2);
      }
| QMARK STRING  PROPERTY {
    int status = 0;
    char *tbl_name = $2;
    char *tbl_prop = $3; tbl_prop += 5; /* jump over PROP= */
    mcr_chk_tbl_name(tbl_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"tbl_meta\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"property\" : \"%s\" \n", tbl_prop);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($2);
    free_if_non_null($3);
      }
| QMARK STRING DOT STRING {
    int status = 0;
    char *tbl_name = $2;
    char *fld_name = $4;
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(fld_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"is_fld\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"fld\" : \"%s\" \n", fld_name);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($2);
    free_if_non_null($4);
      }
| QMARK STRING  DOT STRING ASTERISK {
    int status = 0;
    char *tbl_name = $2;
    char *fld_name = $4;
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(fld_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"fld_meta\", \n");
    sprintf(g_op, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_op, "  \"fld\" : \"%s\", \n", fld_name);
    strcat(g_op, g_buf);
    strcat(g_op, "  \"property\" : \"\" \n");
    strcat(g_op, "} \n");
    free_if_non_null($2);
    free_if_non_null($4);
      }
| QMARK STRING DOT STRING PROPERTY {
    int status = 0;
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
| STRING DOT STRING COLON STRING ASSIGN STRING {
    int status = 0;
    char *tbl_name = $1;
    char *fld_name = $3;
    char *fld_prop = $5; 
    char *prop_val = $7; 
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(fld_name);
    mcr_chk_fld_prop(fld_prop);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"set_meta\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"fld\" : \"%s\", \n", fld_name);
    strcat(g_op, g_buf);
    sprintf(g_op, "  \"property\" : \"%s\" \n", fld_prop);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($1);
    free_if_non_null($3);
    free_if_non_null($5);
    free_if_non_null($7);
      }
| MINUS STRING DOT STRING COLON STRING {
    int status = 0;
    char *tbl_name = $2;
    char *fld_name = $4;
    char *fld_prop = $6; 
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(fld_name);
    mcr_chk_fld_prop(fld_prop);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"unset_meta\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"fld\" : \"%s\", \n", fld_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"property\" : \"%s\" \n", fld_prop);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($2);
    free_if_non_null($4);
    free_if_non_null($6);
      }
| PLUS STRING VERB INT {
    int status = 0;
    char *tbl_name = $2;
    char *op = $3; op += 3; // Jump over OP=
    char *str_num_rows = $4;
    if ( strcasecmp(op, "NEW") !=  0 ) { 
      fprintf(stderr, "Expected [OP=NEW], got %s \n", $3);
      WHEREAMI; return 1;
    }
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_nR(str_num_rows);
    if ( status == 0 ) {
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"add_tbl\", \n");
    sprintf(g_op, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_op, "  \"nR\" : \"%s\" \n", str_num_rows);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    }
    free_if_non_null($2);
    free_if_non_null($3);
    free_if_non_null($4);
      }
| STRING ASSIGN VERB OPTIONS {
  int status = 0;
  char *tbl_name = $1;
  char *op = $3; op += 3; // Jump over OP=
  char *options = $4;
  if ( ( strcasecmp(op, "New")        ==  0 ) ||
      ( strcasecmp(op, "LoadCSV")    ==  0 ) ||
      ( strcasecmp(op, "LoadBinary") ==  0 ) ||
      ( strcasecmp(op, "LoadHDFS")   ==  0 ) ) {
    /* all is well */
    if ( strcasecmp(op, "LoadCSV")    ==  0 ) {
      bool is_null, b_ignore_hdr;
      char fld_sep[16];
      char bool_val[16];
      //----------------------------------------------------
      status = extract_S(options, "datafile=", ",", datafile,
          MAX_LEN_FILE_NAME, &is_null);
      if ( is_null) { WHEREAMI; return 1; }
      if ( status < 0 ) { WHEREAMI; return 1; } 
      //----------------------------------------------------
      status = extract_S(options, "metadatafile=", ",", metadatafile, 
          MAX_LEN_FILE_NAME, &is_null);
      if ( status < 0 ) { WHEREAMI; return 1; } 
      if ( is_null) { WHEREAMI; return 1; }
      //----------------------------------------------------
      status = extract_S(options, "ignore_hdr=", ",", bool_val, 
          16, &is_null);
      if ( status < 0 ) { WHEREAMI; return 1; } 
      if ( is_null) { 
        b_ignore_hdr = false;  // default value 
      }
      else {
        status = stoB(bool_val, &b_ignore_hdr); cBYE(status);
      }
      //----------------------------------------------------
    }
  }
  else {
    fprintf(stderr, "Valid options for adding a table are TODO\n");
    fprintf(stderr, "Got %s \n", $3);
    WHEREAMI; return 1;
  }
  mcr_chk_tbl_name(tbl_name);
  strcat(g_op, "{ \n");
  strcat(g_op, "  \"verb\" : \"add_tbl\", \n");
  sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
  strcat(g_op, g_buf);
  sprintf(g_buf, "  \"options\" : \"%s\" \n", options);
  strcat(g_op, g_buf);
  strcat(g_op, "} \n");
  free_if_non_null($1);
  free_if_non_null($3);
  free_if_non_null($4);

}
| MINUS STRING {
    int status = 0;
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
    int status = 0;
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
| STRING DOT STRING ASSIGN VERB OPTIONS {
    
    int status = 0;
    char *tbl_name = $1;
    char *fld_name = $3;
    char *op       = $5; op += 3; // jump over OP=
    char *options  = $6;
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(fld_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"s_to_f\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"fld\" : \"%s\", \n", fld_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"op\" : \"%s\", \n", op);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"options\" : \"%s\" \n", options);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($1);
    free_if_non_null($3);
    free_if_non_null($5);
    free_if_non_null($6);
      }
| VERB STRING DOT STRING {

    int status = 0;
    char *op = $1; op += 3; // jump over OP=
    char *tbl_name = $2;
    char *fld_name = $4;
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(fld_name);
    if ( ( strcmp(op, "Min") == 0 ) ||
         ( strcmp(op, "Max") == 0 ) ||
         ( strcmp(op, "Sum") == 0 ) ||
         ( strcmp(op, "NumNN") == 0 ) ||
         ( strcmp(op, "NumNDV") == 0 ) ||
         ( strcmp(op, "ApproxNDV") == 0 ) ) {
      /* all is well */
    }
    else {
      go_BYE(-1);
    }

    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"f_to_s\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"fld\" : \"%s\", \n", fld_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"op\" : \"%s\" \n", op);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null($1);
    free_if_non_null($2);
    free_if_non_null($4);
      }
| STRING ADDTO STRING {
    int status = 0;
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
    int status = 0;
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
    int status = 0;
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
    int status = 0;
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
    int status = 0;
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
%%
int yyerror(
    const char *s
    ) 
{
  fprintf(stderr, "EEK, parse error!  Message: [%s]\n", s);
  WHEREAMI;
  return -1;
}
