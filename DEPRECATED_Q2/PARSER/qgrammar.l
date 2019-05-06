%{
#include <stdio.h>
extern  int yylex();

#include "qgrammar.tab.h"
%}
%%
[ \t\n]         ;
[0-9]+\.[0-9]+  { 
  yylval.str_fp  = strdup(yytext); 
  printf("FP  : [%s]\n", yytext); 
  return FP; 
}

[0-9]+          { 
    yylval.str_int = strdup(yytext); return INT; 
}
[a-zA-Z0-9_]+    { 
  /* printf("LEX: STR=[%s]\n", yytext);   */
  yylval.str_str = strdup(yytext); 
  return  STRING;
}
\*       { /* printf("LEX: ASTERISK \n"); */ return ASTERISK;}
[#]      { /* printf("LEX: POUND \n");    */ return POUND;}
[<]      { /* printf("LEX: LT \n");       */ return LT;}
[>]      { /* printf("LEX: GT \n");       */ return GT;}
'<='     { /* printf("LEX: LEQ \n");      */ return LEQ;}
'>='     { /* printf("LEX: GEQ \n");      */ return GEQ; }
'>=&&<=' { /* printf("LEX: GEQANDLEQ \n");*/ return GEQANDLEQ; }
'>&&<'   { /* printf("LEX: GTANDLT \n");  */ return GTANDLT; }
:=       { /* printf("LEX:ASSIGN\n");    */  return ASSIGN; }
\+=      { /* printf("LEX:ADDTO\n");     */  return ADDTO; }
\<-      { /* printf("LEX:MOVE\n");      */  return MOVE; }
[(]      { /* printf("LEX:  Open Round \n"); */  return  OPEN_ROUND; }
[)]      { /* printf("LEX: Close Round \n"); */  return CLOSE_ROUND; }
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
  /* printf("LEX: VERB: %s \n", yytext);     */
  yylval.str_vrb = strdup(yytext);  return VERB; 
}
PROP=[a-zA-Z0-9]+  { 
  /* printf("LEX: PROPERTY=[%s]\n", yytext);   */
  yylval.str_prp = strdup(yytext);  return PROPERTY; 
}
ARGS=\{[/ .a-z,:"'A-Z0-9_=-]+\}  { 
  /* printf("LEX: ARGS: %s\n", yytext); */
  yylval.str_str = strdup(yytext); return  ARGS; }
[\[]     { /* printf("LEX: Open Square \n");  */ return  OPEN_SQUARE; }
[\]]     { /* printf("LEX: Close Square \n"); */ return CLOSE_SQUARE; }
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
