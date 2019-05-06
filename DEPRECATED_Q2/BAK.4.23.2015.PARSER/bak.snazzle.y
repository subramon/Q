%{
#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>
#include <string.h>
#include <inttypes.h>
#include <stdlib.h>
#include "macros.h"
#include "auxil.h"
#include "constants.h"

#define MAX_NUM_FLDS_IN_LIST 32
extern int g_status;
extern int g_num_strings;
extern char g_strings[MAX_NUM_FLDS_IN_LIST][MAX_LEN_FLD_NAME+1];
extern char g_tbl[MAX_LEN_TBL_NAME+1];
extern char g_fld[MAX_LEN_FLD_NAME+1];
extern char g_tbl_2[MAX_LEN_TBL_NAME+1];
extern char g_fld_2[MAX_LEN_FLD_NAME+1];
extern char g_ctbl[MAX_LEN_TBL_NAME+1+MAX_LEN_FLD_NAME+1];
extern char g_cfld[MAX_LEN_FLD_NAME+1];
extern FILE *g_ofp;

#define mcr_chk_tbl_name(x) { \
    if ( !chk_tbl_name(x) ) {  \
      fprintf(stderr, "Invalid Table Name = [%s]\n",  x);  \
      WHEREAMI; exit -1; \
    } \
}

#define mcr_chk_nR(x) {  \
  { \
    long long num_rows; \
    g_status  = stoI8(str_num_rows, &num_rows); \
    if ( ( g_status < 0 ) || ( num_rows <= 0 ) ) { \
      fprintf(stderr, "Invalid Number of Rows = [%s]\n",  str_num_rows); \
      WHEREAMI; exit -1; \
    } \
    } \
}

#define YYDEBUG 1
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
}

%type <str_str> strings
%type <str_str> string_list
%type <str_str> fld_in_tbl
%type <str_str> fld_in_cond_tbl
%type <str_str> cond_tbl

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <str_int> INT
%token <str_fp>  FP
%token <str_str> STRING
%token <str_vrb> VERB
%token <str_opt> OPTIONS
%token <str_kw> KEYWORD
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

/* Tokens containins multiple characters */
%token NOOP
%token LEQ
%token GEQ
%token ASSIGN
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
// this is the actual grammar that bison will parse, but for right now it's just
// something silly to echo to the screen what bison gets from flex.  We'll
// make a real one shortly:
snazzle:
          snazzle INT    { printf("BSN:2 int:    %s\n", $2); }
        | snazzle FP     { printf("BSN:2 float:  %s \n", $2); }
        | snazzle STRING { printf("BSN:2 string: %s\n", $2); }
        | snazzle command { /* printf("BSN:2 command  \n"); */ }
        | INT  {   printf("BSN:1 int   : %s\n", $1); }
        | STRING { printf("BSN:1 string: %s\n", $1); }
        | FP {     printf("BSN:1 float : %s \n", $1); }
        | command { printf("BSN:1 command  \n"); }
        ;

command: QMARK {
    fprintf(g_ofp, "{ \n"); 
    fprintf(g_ofp, "  \"verb\" : \"show_tables\" \n"); 
    fprintf(g_ofp, "} \n"); 
         }
|
command: QMARK STRING {
    int status = 0;
    char *tbl_name = $2;
    mcr_chk_tbl_name(tbl_name);
    if ( status == 0 ) { 
    fprintf(g_ofp, "{ \n"); 
    fprintf(g_ofp, "  \"verb\" : \"tbl_meta\", \n"); 
    fprintf(g_ofp, "  \"tbl\" : \"%s\" \n", tbl_name);
    fprintf(g_ofp, "} \n"); 
    }
      }
 | PLUS STRING VERB { 
    int status = 0;
    char *tbl_name     = $2;
    char *str_num_rows = $3; 
    fprintf(stderr, "verb = %s \n", $3); 
    exit;
    mcr_chk_nR(str_num_rows);
    mcr_chk_tbl_name(tbl_name);
    fprintf(g_ofp, "{ \n"); 
    fprintf(g_ofp, "  \"verb\" : \"add_tbl\", \n"); 
    fprintf(g_ofp, "  \"tbl\" : \"%s\", \n", tbl_name);
    fprintf(g_ofp, "  \"num_rows\" : \"%s\" \n", str_num_rows);
    fprintf(g_ofp, "} \n"); 
    }
 | MINUS STRING { 
    int status = 0;
    char *tbl_name = $2;
    mcr_chk_tbl_name(tbl_name);
    fprintf(g_ofp, "{ \n"); 
    fprintf(g_ofp, "  \"verb\" : \"del_tbl\", \n"); 
    fprintf(g_ofp, "  \"tbl\" : \"%s\" \n", tbl_name);
    fprintf(g_ofp, "} \n"); 
    }
| fld_in_tbl assignment fld_in_tbl { 
  int status = 0;
    status = read_nth_val($1, ".", 0, g_tbl, MAX_LEN_TBL_NAME);
    status = read_nth_val($1, ".", 1, g_fld, MAX_LEN_TBL_NAME);
    mcr_chk_tbl_name(g_tbl);
    mcr_chk_tbl_name(g_fld);

    status = read_nth_val($3, ".", 0, g_tbl_2, MAX_LEN_TBL_NAME);
    status = read_nth_val($3, ".", 1, g_fld_2, MAX_LEN_TBL_NAME);
    mcr_chk_tbl_name(g_tbl_2);
    mcr_chk_tbl_name(g_fld_2);

    if ( ( strcmp(g_tbl, g_tbl_2) == 0 ) && 
         ( strcmp(g_fld, g_fld_2) == 0 ) ) {
      fprintf(g_ofp, "{\n \"verb\" : \"nop\" \n}\n"); 
    }
    else {
      fprintf(g_ofp, "{ \n"); 
      fprintf(g_ofp, "  \"verb\" : \"copy_fld\", \n"); 
      fprintf(g_ofp, "  \"intbl\" : \"%s\" \n", g_tbl);
      fprintf(g_ofp, "  \"infld\" : [%s] \n",   g_fld);
      fprintf(g_ofp, "  \"outtbl\" : \"%s\" \n", g_tbl);
      fprintf(g_ofp, "  \"outfld\" : [%s] \n",   g_fld);
      fprintf(g_ofp, "} \n"); 
    }

    zero_string_to_nullc(g_tbl);
    zero_string_to_nullc(g_fld);
    zero_string_to_nullc(g_tbl_2);
    zero_string_to_nullc(g_fld_2);

}
| fld_in_tbl replace fld_in_tbl { 
  int status = 0;
    status = read_nth_val($1, ".", 0, g_tbl, MAX_LEN_TBL_NAME);
    status = read_nth_val($1, ".", 1, g_fld, MAX_LEN_TBL_NAME);
    mcr_chk_tbl_name(g_tbl);
    mcr_chk_tbl_name(g_fld);

    status = read_nth_val($3, ".", 0, g_tbl_2, MAX_LEN_TBL_NAME);
    status = read_nth_val($3, ".", 1, g_fld_2, MAX_LEN_TBL_NAME);
    mcr_chk_tbl_name(g_tbl_2);
    mcr_chk_tbl_name(g_fld_2);

    if ( ( strcmp(g_tbl, g_tbl_2) == 0 ) && 
         ( strcmp(g_fld, g_fld_2) == 0 ) ) {
      fprintf(g_ofp, "{\n \"verb\" : \"nop\" \n}\n"); 
    }
    else {
      fprintf(g_ofp, "{ \n"); 
      fprintf(g_ofp, "  \"verb\" : \"mv_fld\", \n"); 
      fprintf(g_ofp, "  \"intbl\" : \"%s\" \n", g_tbl);
      fprintf(g_ofp, "  \"infld\" : [%s] \n",   g_fld);
      fprintf(g_ofp, "  \"outtbl\" : \"%s\" \n", g_tbl);
      fprintf(g_ofp, "  \"outfld\" : [%s] \n",   g_fld);
      fprintf(g_ofp, "} \n"); 
    }

    zero_string_to_nullc(g_tbl);
    zero_string_to_nullc(g_fld);
    zero_string_to_nullc(g_tbl_2);
    zero_string_to_nullc(g_fld_2);

}
 | MINUS fld_in_tbl {
    int status = 0, n;
    /* Cannot be conditional table */
    status = count_char($2, '|', &n);
    if ( n > 0 ) { WHEREAMI; exit; }
    status = read_nth_val($2, ".", 0, g_tbl, MAX_LEN_TBL_NAME);
    status = read_nth_val($2, ".", 1, g_fld, MAX_LEN_TBL_NAME);
    mcr_chk_tbl_name(g_tbl);
    mcr_chk_tbl_name(g_fld);
    fprintf(g_ofp, "{ \n"); 
    fprintf(g_ofp, "  \"verb\" : \"del_fld\", \n"); 
    fprintf(g_ofp, "  \"tbl\" : \"%s\", \n", g_tbl);
    fprintf(g_ofp, "  \"fld\" : \"%s\" \n", g_fld);
    fprintf(g_ofp, "} \n"); 
    zero_string(g_tbl, MAX_LEN_TBL_NAME+1);
    zero_string(g_fld, MAX_LEN_TBL_NAME+1);
    }
  | MINUS STRING DOT strings { 
    int status = 0;
    char *tbl_name = $2; int num_flds;
    status = count_char($4, ',', &num_flds); num_flds++;
    mcr_chk_tbl_name(tbl_name);
    fprintf(g_ofp, "{ \n"); 
    fprintf(g_ofp, "  \"verb\" : \"del_fld\", \n"); 
    fprintf(g_ofp, "  \"tbl\" : \"%s\", \n", tbl_name);
    fprintf(g_ofp, "  \"num_flds\" : \"%d\" \n", g_num_strings); 
    fprintf(g_ofp, "  \"fld\" : ["); 
    for ( int i = 0; i < g_num_strings; i++ ) { 
      status = read_nth_val($4, ",", i, g_fld, MAX_LEN_FLD_NAME);

      fprintf(g_ofp, "  \"%s\" ",  g_fld);
      if ( i != (g_num_strings-1) ) {
        fprintf(g_ofp, ", "); 
      }
      else {
        fprintf(g_ofp, " "); 
      }
      zero_string(g_strings[i], MAX_LEN_FLD_NAME+1);
    }
    g_num_strings = 0;
    fprintf(g_ofp, "  ] \n");
    fprintf(g_ofp, "} \n"); 
  }
  | STRING OPEN_ROUND fld_in_tbl CLOSE_ROUND
{
  int status = 0;
  char *reduce_op = $1;
  for ( char *cptr = reduce_op; *cptr !=  '\0'; ) { 
    *reduce_op++ = tolower(*cptr++);
  }
  reduce_op = $1;
  if ( ( strcasecmp(reduce_op, "sum" ) == 0 ) || 
       ( strcasecmp(reduce_op, "min" ) == 0 ) || 
       ( strcasecmp(reduce_op, "max" ) == 0 ) || 
       ( strcasecmp(reduce_op, "ndv" ) == 0 ) || 
       ( strcasecmp(reduce_op, "approx_ndv" ) == 0 ) || 
       ( strcasecmp(reduce_op, "num_nn" ) == 0 ) ) {
    /* all is well */
  }
  else {
    WHEREAMI; exit -1; 
  }
  bool is_ctbl;
  status = read_nth_val($3, ".", 0, g_tbl, MAX_LEN_TBL_NAME);
  status = read_nth_val($3, ".", 1, g_fld, MAX_LEN_TBL_NAME);
  chk_tbl_name(g_tbl);
  chk_tbl_name(g_fld);

  fprintf(g_ofp, "{ \n"); 
  fprintf(g_ofp, "  \"verb\" : \"reduce\", \n"); 
  fprintf(g_ofp, "  \"op\" : \"%s\", \n", $1);
  fprintf(g_ofp, "  \"tbl\" : \"%s\", \n", g_tbl);
  fprintf(g_ofp, "  \"fld\" : \"%s\" \n", g_fld); 
  fprintf(g_ofp, "{ \n"); 
}
  | STRING OPEN_ROUND fld_in_cond_tbl CLOSE_ROUND
{
  int status = 0;
  char *reduce_op = $1;
  for ( char *cptr = reduce_op; *cptr !=  '\0'; ) { 
    *reduce_op++ = tolower(*cptr++);
  }
  reduce_op = $1;
  if ( ( strcasecmp(reduce_op, "sum" ) == 0 ) || 
       ( strcasecmp(reduce_op, "min" ) == 0 ) || 
       ( strcasecmp(reduce_op, "max" ) == 0 ) || 
       ( strcasecmp(reduce_op, "ndv" ) == 0 ) || 
       ( strcasecmp(reduce_op, "approx_ndv" ) == 0 ) || 
       ( strcasecmp(reduce_op, "num_nn" ) == 0 ) ) {
    /* all is well */
  }
  else {
    WHEREAMI; exit -1; 
  }
  bool is_ctbl;
  status = read_nth_val($3, ".", 0, g_ctbl, MAX_LEN_TBL_NAME);
  status = read_nth_val($3, ".", 1, g_fld, MAX_LEN_TBL_NAME);
  status = chk_is_ctbl(g_ctbl, &is_ctbl);
  if ( is_ctbl ) { 
    status = read_nth_val(g_ctbl, "|", 0, g_tbl, MAX_LEN_TBL_NAME);
    status = read_nth_val(g_ctbl, "|", 1, g_cfld, MAX_LEN_TBL_NAME);
    chk_tbl_name(g_cfld);
  }
  else {
    strcpy(g_tbl, g_ctbl);
  }
//  printf("g_tbl = %s \n",  g_tbl);
//  printf("g_ctbl = %s \n",  g_ctbl);
  chk_tbl_name(g_tbl);
  chk_tbl_name(g_fld);
 // printf("======\n");

  fprintf(g_ofp, "{ \n"); 
  fprintf(g_ofp, "  \"verb\" : \"reduce\", \n"); 
  fprintf(g_ofp, "  \"op\" : \"%s\", \n", $1);
  fprintf(g_ofp, "  \"tbl\" : \"%s\", \n", g_tbl);
  if ( g_cfld[0] != '\0' ) { 
    fprintf(g_ofp, "  \"cfld\" : \"%s\", \n", g_cfld);
  }
  fprintf(g_ofp, "  \"fld\" : \"%s\" \n", g_fld); 
  fprintf(g_ofp, "{ \n"); 
}
;


cond_tbl : STRING VBAR STRING
{
  char *tbl  = $1;
  char *cfld = $3;
  char *cptr = NULL;
  mcr_chk_tbl_name(tbl);
  mcr_chk_tbl_name(cfld);
  cptr = malloc(strlen(tbl) + strlen(cfld) + 4);
  strcpy(cptr, tbl); strcat(cptr, "|"); strcat(cptr, cfld);
  $$ = cptr;
}

fld_in_tbl : STRING DOT STRING 
{
  char *tbl  = $1;
  char *fld  = $3;
  char *cptr = NULL;
  mcr_chk_tbl_name(tbl);
  mcr_chk_tbl_name(fld);
  cptr = malloc(strlen(tbl) + strlen(fld) + 4);
  strcpy(cptr, tbl); strcat(cptr, "."); strcat(cptr, fld);
  $$ = cptr;
}
fld_in_cond_tbl : cond_tbl DOT STRING 
{
  char *cond_tbl  = $1;
  char *fld  = $3;
  char *cptr = NULL;
  mcr_chk_tbl_name(fld);
  cptr = malloc(strlen(cond_tbl) + strlen(fld) + 4);
  strcpy(cptr, cond_tbl); strcat(cptr, "."); strcat(cptr, fld);
  $$ = cptr;
}

;

strings : OPEN_CURLY string_list CLOSE_CURLY
{
  $$ = strdup($2); free($2);
}
string_list : STRING 
{
  $$ = strdup($1); 
  if ( g_num_strings == MAX_NUM_FLDS_IN_LIST ) { WHEREAMI; exit -1; }
  char *fld_name = $1;
  mcr_chk_tbl_name(fld_name);
  strcpy(g_strings[g_num_strings++], fld_name);
  // printf("fld_list:1 %d => %s \n", g_num_strings, fld_name);
  free($1);
}
  | string_list COMMA STRING
{
  int len; char *cptr; 
  len = strlen($1) + strlen($3) + 4;
  cptr = malloc(len);
  strcpy(cptr, $1); strcat(cptr, ","); strcat(cptr, $3);
  $$ = cptr;
  if ( g_num_strings == MAX_NUM_FLDS_IN_LIST ) { WHEREAMI; exit -1; }
  char *fld_name = $3;
  mcr_chk_tbl_name(fld_name);
  strcpy(g_strings[g_num_strings++], fld_name);
  // printf("fld_list:2 %d => %s \n", g_num_strings, fld_name);
  free($3); free($1);
}
  ;
%%
#define YYDEBUG 1
int g_status;
char g_strings[MAX_NUM_FLDS_IN_LIST][MAX_LEN_FLD_NAME+1];
int g_num_strings;

char g_tbl[MAX_LEN_TBL_NAME+1];
char g_fld[MAX_LEN_FLD_NAME+1];

char g_tbl_2[MAX_LEN_TBL_NAME+1];
char g_fld_2[MAX_LEN_FLD_NAME+1];

char g_ctbl[MAX_LEN_TBL_NAME+1+MAX_LEN_FLD_NAME+1];
char g_cfld[MAX_LEN_FLD_NAME+1];

FILE *g_ofp;
int 
main(
    int argc,
    char **argv
    ) 
{
  int status = 0;
  FILE *ifp = NULL;
  // lex through the input:

  g_ofp = NULL;
  g_num_strings = 0;
  yydebug = 0;
  if ( argc != 3 ) { go_BYE(-1); }
  char *infile = argv[1];
  char *opfile = argv[2];
  // open a file handle to a particular file:
  ifp = fopen(infile, "r");
  return_if_fopen_failed(ifp, infile, "r");
  // open json file for output
  g_ofp = fopen(opfile, "w");
  return_if_fopen_failed(g_ofp, opfile, "w");
  // make sure it's valid:
  // set lex to read from it instead of defaulting to STDIN:
  yyin = ifp;
  yylex();
  do {
    status = yyparse();
    cBYE(status);
  } while (!feof(yyin));

  for ( int i = 0; i < g_num_strings; i++ ) { 
    fprintf(stderr, "%d => %s \n", i, g_strings[i]);
  }

BYE:
  fclose_if_non_null(ifp);
  fclose_if_non_null(g_ofp);
  return status;
}

int yyerror(
    const char *s
    ) 
{
  fprintf(stderr, "EEK, parse error!  Message: [%s]\n", s);
  WHEREAMI;
  return -1;
}
/*
#define YYPRINT(file, type, value)   yyprint (file, type, value)

static void
yyprint (FILE *file,
    int type,
    YYSTYPE value
    )
{
  if (type == VAR)
    fprintf (file, " %s", value.tptr->name);
  else if (type == NUM)
    fprintf (file, " %d", value.val);
}
*/
