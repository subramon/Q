/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_QGRAMMAR_TAB_H_INCLUDED
# define YY_YY_QGRAMMAR_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    INT = 258,
    FP = 259,
    STRING = 260,
    VERB = 261,
    OPTIONS = 262,
    KEYWORD = 263,
    PROPERTY = 264,
    VBAR = 265,
    MINUS = 266,
    PLUS = 267,
    DOT = 268,
    QMARK = 269,
    COLON = 270,
    EQUALS = 271,
    COMMA = 272,
    LT = 273,
    GT = 274,
    ASTERISK = 275,
    NOOP = 276,
    LEQ = 277,
    GEQ = 278,
    ASSIGN = 279,
    ADDTO = 280,
    MOVE = 281,
    GEQANDLEQ = 282,
    GTANDLT = 283,
    LEQORGEQ = 284,
    LTORGT = 285,
    OPEN_CURLY = 286,
    CLOSE_CURLY = 287,
    OPEN_SQUARE = 288,
    CLOSE_SQUARE = 289,
    OPEN_ROUND = 290,
    CLOSE_ROUND = 291,
    ADD_TBL = 292,
    ADD_FLD = 293,
    DEL_TBL = 294,
    DEL_FLD = 295
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE YYSTYPE;
union YYSTYPE
{
#line 76 "qgrammar.y" /* yacc.c:1909  */

        char *str_int;
        char *str_fp;
        char *str_str;
        char *str_vrb;
        char *str_opt;
        char *str_kw;
        char *str_prp;
        char *str_tof; /* tof = Table Or Field */

#line 106 "qgrammar.tab.h" /* yacc.c:1909  */
};
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_QGRAMMAR_TAB_H_INCLUDED  */
