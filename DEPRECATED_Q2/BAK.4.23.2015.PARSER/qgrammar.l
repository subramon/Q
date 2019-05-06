%{
#include <stdio.h>
extern  int yylex();

#include "snazzle.tab.h"
%}
%%
[ \t\n]         ;
[0-9]+\.[0-9]+  { 
  yylval.str_fp  = strdup(yytext); 
  printf("FP  : [%s]\n", yytext); 
  return FP; 
}
add_tbl         { return ADD_TBL; }
add_fld         { return ADD_FLD; }
del_tbl         { return DEL_TBL; }
del_fld         { return DEL_FLD; }

[0-9]+          { 
  printf("INT : [%s]\n", yytext); 
    yylval.str_int = strdup(yytext); return INT; 
}
[a-zA-Z0-9_]+    { 
  /* printf("STR : [%s]\n", yytext); */
  yylval.str_str = strdup(yytext); 
  return  STRING;
}
\*       { /* printf("LEX: ASTERISK \n"); */ return ASTERISK;}
[<]      { /* printf("LEX: LT \n");       */ return LT;}
[>]      { /* printf("LEX: GT \n");       */ return GT;}
'<='     { /* printf("LEX: LEQ \n");      */ return LEQ;}
'>='     { /* printf("LEX: GEQ \n");      */ return GEQ; }
'>=&&<=' { /* printf("LEX: GEQANDLEQ \n");*/ return GEQANDLEQ; }
'>&&<'   { /* printf("LEX: GTANDLT \n");  */ return GTANDLT; }
:=       { /* printf("LEX:ASSIGN\n");    */  return ASSIGN; }
\+=      { /* printf("LEX:ADDTO\n");     */  return ADDTO; }
\<-      { /* printf("LEX:MOVE\n");      */  return MOVE; }
[|]      { /* printf("LEX: VBAR \n");    */  return VBAR;}
[-]      { /* printf("LEX:MINUS \n");    */  return MINUS;}
[+]      { /* printf("LEX:PLUS \n");     */  return PLUS;}
[,]      { /* printf("LEX:COMMA \n");    */  return COMMA;}
[.]      { /* printf("LEX:DOT \n");      */  return DOT;}
[?]      { /* printf("LEX:QMARK \n");    */  return QMARK; }
[:]      { /* printf("LEX:Colon \n");    */  return COLON; }
[=]      { /* printf("LEX:Equals \n");   */  return EQUALS; }
KW=[a-zA-Z0-9]+  { 
           /* printf("LEX: KW\n");       */ 
           yylval.str_kw = strdup(yytext);   return KEYWORD; } 
OP=[a-zA-Z0-9]+  { 
  /* printf("LEX: VERB: %s \n", yytext);    */
  yylval.str_vrb = strdup(yytext);  return VERB; 
}
PROP=[a-zA-Z0-9]+  { 
  /* printf("LEX: PROPERTY\n"); */
  yylval.str_prp = strdup(yytext);  return PROPERTY; 
}
\([a-z,:A-Z0-9_=]+\)  { 
  /* printf("LEX: OPTIONS: %s\n", yytext); */
  yylval.str_str = strdup(yytext); return  OPTIONS; }
[)]      { /* printf("LEX: Close Round \n");  */ return CLOSE_ROUND; }
[\[]     { /* printf("LEX: Open Square \n");  */ return OPEN_SQUARE; }
[\]]     { /* printf("LEX: Close Square \n"); */ return CLOSE_SQUARE; }
[{]      { /* printf("LEX: Open Curly \n");   */ return OPEN_CURLY; }
[}]      { /* printf("LEX: Close Curly \n");  */ return CLOSE_CURLY; }
%%
/*
#include "macros.h"
int 
main(
int argc,
char **argv
) 
{
  int status = 0;
  FILE *ifp = NULL;
  // lex through the input:

  if ( argc != 2 ) { go_BYE(-1); }
  char *infile = argv[1];
  // open a file handle to a particular file:
  ifp = fopen(infile, "r");
  return_if_fopen_failed(ifp, infile, "r");
  // make sure it's valid:
  // set lex to read from it instead of defaulting to STDIN:
  yyin = ifp;
  yylex();
BYE:
  fclose_if_non_null(ifp);
  return status;
}
*/
