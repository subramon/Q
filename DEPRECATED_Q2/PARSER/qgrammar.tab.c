/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison implementation for Yacc-like parsers in C

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

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "3.0.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* Copy the first part of user declarations.  */
#line 1 "qgrammar.y" /* yacc.c:339  */

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


#line 173 "qgrammar.tab.c" /* yacc.c:339  */

# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* In a future release of Bison, this section will be replaced
   by #include "qgrammar.tab.h".  */
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
    ARGS = 262,
    KEYWORD = 263,
    PROPERTY = 264,
    TBL = 265,
    VBAR = 266,
    MINUS = 267,
    PLUS = 268,
    DOT = 269,
    QMARK = 270,
    COLON = 271,
    EQUALS = 272,
    COMMA = 273,
    LT = 274,
    GT = 275,
    ASTERISK = 276,
    POUND = 277,
    NOOP = 278,
    LEQ = 279,
    GEQ = 280,
    ASSIGN = 281,
    ADDTO = 282,
    MOVE = 283,
    GEQANDLEQ = 284,
    GTANDLT = 285,
    LEQORGEQ = 286,
    LTORGT = 287,
    OPEN_SQUARE = 288,
    CLOSE_SQUARE = 289,
    OPEN_ROUND = 290,
    CLOSE_ROUND = 291
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE YYSTYPE;
union YYSTYPE
{
#line 113 "qgrammar.y" /* yacc.c:355  */

        char *str_int;
        char *str_fp;
        char *str_str;
        char *str_vrb;
        char *str_arg;
        char *str_kw;
        char *str_prp;

#line 260 "qgrammar.tab.c" /* yacc.c:355  */
};
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_QGRAMMAR_TAB_H_INCLUDED  */

/* Copy the second part of user declarations.  */

#line 275 "qgrammar.tab.c" /* yacc.c:358  */

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif

#ifndef YY_ATTRIBUTE
# if (defined __GNUC__                                               \
      && (2 < __GNUC__ || (__GNUC__ == 2 && 96 <= __GNUC_MINOR__)))  \
     || defined __SUNPRO_C && 0x5110 <= __SUNPRO_C
#  define YY_ATTRIBUTE(Spec) __attribute__(Spec)
# else
#  define YY_ATTRIBUTE(Spec) /* empty */
# endif
#endif

#ifndef YY_ATTRIBUTE_PURE
# define YY_ATTRIBUTE_PURE   YY_ATTRIBUTE ((__pure__))
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# define YY_ATTRIBUTE_UNUSED YY_ATTRIBUTE ((__unused__))
#endif

#if !defined _Noreturn \
     && (!defined __STDC_VERSION__ || __STDC_VERSION__ < 201112)
# if defined _MSC_VER && 1200 <= _MSC_VER
#  define _Noreturn __declspec (noreturn)
# else
#  define _Noreturn YY_ATTRIBUTE ((__noreturn__))
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(E) ((void) (E))
#else
# define YYUSE(E) /* empty */
#endif

#if defined __GNUC__ && 407 <= __GNUC__ * 100 + __GNUC_MINOR__
/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN \
    _Pragma ("GCC diagnostic push") \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")\
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# define YY_IGNORE_MAYBE_UNINITIALIZED_END \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif


#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYSIZE_T yynewbytes;                                            \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / sizeof (*yyptr);                          \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, (Count) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYSIZE_T yyi;                         \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  21
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   72

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  37
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  5
/* YYNRULES -- Number of rules.  */
#define YYNRULES  32
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  77

/* YYTRANSLATE[YYX] -- Symbol number corresponding to YYX as returned
   by yylex, with out-of-bounds checking.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   291

#define YYTRANSLATE(YYX)                                                \
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, without out-of-bounds checking.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36
};

#if YYDEBUG
  /* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   167,   167,   172,   181,   193,   205,   216,   227,   242,
     258,   274,   293,   316,   337,   355,   366,   381,   423,   459,
     493,   552,   567,   582,   597,   627,   664,   675,   710,   729,
     733,   743,   755
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || 0
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "INT", "FP", "STRING", "VERB", "ARGS",
  "KEYWORD", "PROPERTY", "TBL", "VBAR", "MINUS", "PLUS", "DOT", "QMARK",
  "COLON", "EQUALS", "COMMA", "LT", "GT", "ASTERISK", "POUND", "NOOP",
  "LEQ", "GEQ", "ASSIGN", "ADDTO", "MOVE", "GEQANDLEQ", "GTANDLT",
  "LEQORGEQ", "LTORGT", "OPEN_SQUARE", "CLOSE_SQUARE", "OPEN_ROUND",
  "CLOSE_ROUND", "$accept", "command", "CTBL", "XARGS", "PROPERTY_VAL", YY_NULLPTR
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[NUM] -- (External) token number corresponding to the
   (internal) symbol number NUM (which must be that of a token).  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291
};
# endif

#define YYPACT_NINF -43

#define yypact_value_is_default(Yystate) \
  (!!((Yystate) == (-43)))

#define YYTABLE_NINF -1

#define yytable_value_is_error(Yytable_value) \
  0

  /* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
     STATE-NUM.  */
static const yytype_int8 yypact[] =
{
      -2,   -12,    29,    30,    31,    32,    33,    34,    40,    36,
      16,    37,    38,    39,    -6,    35,    41,    42,     3,   -43,
     -43,   -43,   -19,   -43,    43,   -43,   -43,    19,    11,    46,
      47,    48,    49,   -43,    52,   -43,    25,    53,   -43,    54,
      22,    55,    55,    50,    56,    -3,    57,    59,    58,    62,
      44,    -4,   -43,   -43,   -43,   -43,    23,   -43,   -43,    63,
     -43,    64,    12,    27,    65,   -43,   -43,   -43,   -43,   -43,
     -43,    55,   -43,    28,   -43,    55,   -43
};

  /* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
     Performed when YYTABLE does not specify something else to do.  Zero
     means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       0,     0,     3,     0,     0,     2,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    15,     0,     6,     5,
       4,     1,     0,    22,     0,    21,    23,     0,     0,     0,
       0,     0,     0,     8,     0,     7,     0,     0,    14,     0,
       0,    29,    29,    16,     0,     9,     0,     0,     0,     0,
       0,     0,    30,    19,    20,    13,     0,    11,    10,     0,
      17,     0,     0,     0,     0,    26,    31,    32,    12,    24,
      25,    29,    27,     0,    18,    29,    28
};

  /* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
     -43,   -43,   -43,   -42,   -43
};

  /* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
      -1,     8,    15,    53,    68
};

  /* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
     positive, shift that token.  If negative, reduce the rule whose
     number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_uint8 yytable[] =
{
      54,    64,     9,     1,     2,    28,    57,    36,    29,    37,
       3,     4,    33,     5,    10,    11,    12,    34,    58,     6,
       7,    23,    24,    13,    35,    50,    66,    51,    67,    74,
      46,    47,    65,    76,    14,    16,    17,    18,    19,    20,
      21,    22,    25,    26,    27,    39,    40,    63,    71,    30,
      38,    41,    42,    43,    44,    31,    32,    45,    48,    55,
      49,     0,    52,    72,    75,    56,    60,    62,    69,    70,
      73,    59,    61
};

static const yytype_int8 yycheck[] =
{
      42,     5,    14,     5,     6,    11,     9,    26,    14,    28,
      12,    13,     9,    15,    26,    27,    28,    14,    21,    21,
      22,     5,     6,    35,    21,     3,     3,     5,     5,    71,
       5,     6,    36,    75,     5,     5,     5,     5,     5,     5,
       0,     5,     5,     5,     5,    26,    35,     3,    36,    14,
       7,     5,     5,     5,     5,    14,    14,     5,     5,     9,
       6,    -1,     7,    36,    36,     9,     7,     5,     5,     5,
       5,    14,    14
};

  /* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
     symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     5,     6,    12,    13,    15,    21,    22,    38,    14,
      26,    27,    28,    35,     5,    39,     5,     5,     5,     5,
       5,     0,     5,     5,     6,     5,     5,     5,    11,    14,
      14,    14,    14,     9,    14,    21,    26,    28,     7,    26,
      35,     5,     5,     5,     5,     5,     5,     6,     5,     6,
       3,     5,     7,    40,    40,     9,     9,     9,    21,    14,
       7,    14,     5,     3,     5,    36,     3,     5,    41,     5,
       5,    36,    36,     5,    40,    36,    40
};

  /* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    37,    38,    38,    38,    38,    38,    38,    38,    38,
      38,    38,    38,    38,    38,    38,    38,    38,    38,    38,
      38,    38,    38,    38,    38,    38,    39,    39,    39,    40,
      40,    41,    41
};

  /* YYR2[YYN] -- Number of symbols on the right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     1,     1,     2,     2,     2,     3,     3,     4,
       5,     5,     6,     5,     4,     2,     4,     6,     8,     5,
       5,     3,     3,     3,     7,     7,     5,     6,     8,     0,
       1,     1,     1
};


#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)
#define YYEMPTY         (-2)
#define YYEOF           0

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                  \
do                                                              \
  if (yychar == YYEMPTY)                                        \
    {                                                           \
      yychar = (Token);                                         \
      yylval = (Value);                                         \
      YYPOPSTACK (yylen);                                       \
      yystate = *yyssp;                                         \
      goto yybackup;                                            \
    }                                                           \
  else                                                          \
    {                                                           \
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;                                                  \
    }                                                           \
while (0)

/* Error token number */
#define YYTERROR        1
#define YYERRCODE       256



/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)

/* This macro is provided for backward compatibility. */
#ifndef YY_LOCATION_PRINT
# define YY_LOCATION_PRINT(File, Loc) ((void) 0)
#endif


# define YY_SYMBOL_PRINT(Title, Type, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Type, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*----------------------------------------.
| Print this symbol's value on YYOUTPUT.  |
`----------------------------------------*/

static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
{
  FILE *yyo = yyoutput;
  YYUSE (yyo);
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# endif
  YYUSE (yytype);
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyoutput, "%s %s (",
             yytype < YYNTOKENS ? "token" : "nterm", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yytype_int16 *yybottom, yytype_int16 *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yytype_int16 *yyssp, YYSTYPE *yyvsp, int yyrule)
{
  unsigned long int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       yystos[yyssp[yyi + 1 - yynrhs]],
                       &(yyvsp[(yyi + 1) - (yynrhs)])
                                              );
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif


#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
yystrlen (const char *yystr)
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
yystpcpy (char *yydest, const char *yysrc)
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
        switch (*++yyp)
          {
          case '\'':
          case ',':
            goto do_not_strip_quotes;

          case '\\':
            if (*++yyp != '\\')
              goto do_not_strip_quotes;
            /* Fall through.  */
          default:
            if (yyres)
              yyres[yyn] = *yyp;
            yyn++;
            break;

          case '"':
            if (yyres)
              yyres[yyn] = '\0';
            return yyn;
          }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into *YYMSG, which is of size *YYMSG_ALLOC, an error message
   about the unexpected token YYTOKEN for the state stack whose top is
   YYSSP.

   Return 0 if *YYMSG was successfully written.  Return 1 if *YYMSG is
   not large enough to hold the message.  In that case, also set
   *YYMSG_ALLOC to the required number of bytes.  Return 2 if the
   required number of bytes is too large to store.  */
static int
yysyntax_error (YYSIZE_T *yymsg_alloc, char **yymsg,
                yytype_int16 *yyssp, int yytoken)
{
  YYSIZE_T yysize0 = yytnamerr (YY_NULLPTR, yytname[yytoken]);
  YYSIZE_T yysize = yysize0;
  enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
  /* Internationalized format string. */
  const char *yyformat = YY_NULLPTR;
  /* Arguments of yyformat. */
  char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
  /* Number of reported tokens (one for the "unexpected", one per
     "expected"). */
  int yycount = 0;

  /* There are many possibilities here to consider:
     - If this state is a consistent state with a default action, then
       the only way this function was invoked is if the default action
       is an error action.  In that case, don't check for expected
       tokens because there are none.
     - The only way there can be no lookahead present (in yychar) is if
       this state is a consistent state with a default action.  Thus,
       detecting the absence of a lookahead is sufficient to determine
       that there is no unexpected or expected token to report.  In that
       case, just report a simple "syntax error".
     - Don't assume there isn't a lookahead just because this state is a
       consistent state with a default action.  There might have been a
       previous inconsistent state, consistent state with a non-default
       action, or user semantic action that manipulated yychar.
     - Of course, the expected token list depends on states to have
       correct lookahead information, and it depends on the parser not
       to perform extra reductions after fetching a lookahead from the
       scanner and before detecting a syntax error.  Thus, state merging
       (from LALR or IELR) and default reductions corrupt the expected
       token list.  However, the list is correct for canonical LR with
       one exception: it will still contain any token that will not be
       accepted due to an error action in a later state.
  */
  if (yytoken != YYEMPTY)
    {
      int yyn = yypact[*yyssp];
      yyarg[yycount++] = yytname[yytoken];
      if (!yypact_value_is_default (yyn))
        {
          /* Start YYX at -YYN if negative to avoid negative indexes in
             YYCHECK.  In other words, skip the first -YYN actions for
             this state because they are default actions.  */
          int yyxbegin = yyn < 0 ? -yyn : 0;
          /* Stay within bounds of both yycheck and yytname.  */
          int yychecklim = YYLAST - yyn + 1;
          int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
          int yyx;

          for (yyx = yyxbegin; yyx < yyxend; ++yyx)
            if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR
                && !yytable_value_is_error (yytable[yyx + yyn]))
              {
                if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
                  {
                    yycount = 1;
                    yysize = yysize0;
                    break;
                  }
                yyarg[yycount++] = yytname[yyx];
                {
                  YYSIZE_T yysize1 = yysize + yytnamerr (YY_NULLPTR, yytname[yyx]);
                  if (! (yysize <= yysize1
                         && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
                    return 2;
                  yysize = yysize1;
                }
              }
        }
    }

  switch (yycount)
    {
# define YYCASE_(N, S)                      \
      case N:                               \
        yyformat = S;                       \
      break
      YYCASE_(0, YY_("syntax error"));
      YYCASE_(1, YY_("syntax error, unexpected %s"));
      YYCASE_(2, YY_("syntax error, unexpected %s, expecting %s"));
      YYCASE_(3, YY_("syntax error, unexpected %s, expecting %s or %s"));
      YYCASE_(4, YY_("syntax error, unexpected %s, expecting %s or %s or %s"));
      YYCASE_(5, YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s"));
# undef YYCASE_
    }

  {
    YYSIZE_T yysize1 = yysize + yystrlen (yyformat);
    if (! (yysize <= yysize1 && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
      return 2;
    yysize = yysize1;
  }

  if (*yymsg_alloc < yysize)
    {
      *yymsg_alloc = 2 * yysize;
      if (! (yysize <= *yymsg_alloc
             && *yymsg_alloc <= YYSTACK_ALLOC_MAXIMUM))
        *yymsg_alloc = YYSTACK_ALLOC_MAXIMUM;
      return 1;
    }

  /* Avoid sprintf, as that infringes on the user's name space.
     Don't have undefined behavior even if the translation
     produced a string with the wrong number of "%s"s.  */
  {
    char *yyp = *yymsg;
    int yyi = 0;
    while ((*yyp = *yyformat) != '\0')
      if (*yyp == '%' && yyformat[1] == 's' && yyi < yycount)
        {
          yyp += yytnamerr (yyp, yyarg[yyi++]);
          yyformat += 2;
        }
      else
        {
          yyp++;
          yyformat++;
        }
  }
  return 0;
}
#endif /* YYERROR_VERBOSE */

/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
{
  YYUSE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YYUSE (yytype);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}




/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;


/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    int yystate;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus;

    /* The stacks and their tools:
       'yyss': related to states.
       'yyvs': related to semantic values.

       Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* The state stack.  */
    yytype_int16 yyssa[YYINITDEPTH];
    yytype_int16 *yyss;
    yytype_int16 *yyssp;

    /* The semantic value stack.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs;
    YYSTYPE *yyvsp;

    YYSIZE_T yystacksize;

  int yyn;
  int yyresult;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken = 0;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;

#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  yyssp = yyss = yyssa;
  yyvsp = yyvs = yyvsa;
  yystacksize = YYINITDEPTH;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY; /* Cause a token to be read.  */
  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        YYSTYPE *yyvs1 = yyvs;
        yytype_int16 *yyss1 = yyss;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * sizeof (*yyssp),
                    &yyvs1, yysize * sizeof (*yyvsp),
                    &yystacksize);

        yyss = yyss1;
        yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yytype_int16 *yyss1 = yyss;
        union yyalloc *yyptr =
          (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
        if (! yyptr)
          goto yyexhaustedlab;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
                  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token.  */
  yychar = YYEMPTY;

  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:
#line 167 "qgrammar.y" /* yacc.c:1646  */
    {
    strcat(g_op, "{ \n"); 
    strcat(g_op, "  \"verb\" : \"show_tables\" \n"); 
    strcat(g_op, "} \n"); 
         }
#line 1399 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 3:
#line 172 "qgrammar.y" /* yacc.c:1646  */
    {
    char *op = (yyvsp[0].str_vrb); op += 3; // Jump over OP=
    if ( strcasecmp(op, "NONE") !=  0 ) { 
      sprintf(g_err, "Expected [OP=NONE], got %s \n", (yyvsp[0].str_vrb));
      WHEREAMI; return -1;
    }
    strcat(g_op, "{\n  \"verb\" : \"noop\"\n} \n");
    free((yyvsp[0].str_vrb));
}
#line 1413 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 4:
#line 181 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_name = (yyvsp[0].str_str);
    mcr_chk_tbl_name(tbl_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"tbl_meta\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"property\" : \"NumRows\" \n");
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free((yyvsp[0].str_str));
      }
#line 1430 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 5:
#line 193 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_name = (yyvsp[0].str_str);
    mcr_chk_tbl_name(tbl_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"tbl_meta\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"property\" : \"Fields\" \n");
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free((yyvsp[0].str_str));
      }
#line 1447 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 6:
#line 205 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_name = (yyvsp[0].str_str);
    mcr_chk_tbl_name(tbl_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"tbl_meta\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    strcat(g_op, "  \"property\" : \"Exists\" \n");
    strcat(g_op, "} \n");
    free((yyvsp[0].str_str));
      }
#line 1463 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 7:
#line 216 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_name = (yyvsp[-1].str_str);
    mcr_chk_tbl_name(tbl_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"tbl_meta\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    strcat(g_op, "  \"property\" : \"All\" \n");
    strcat(g_op, "} \n");
    free((yyvsp[-1].str_str));
      }
#line 1479 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 8:
#line 227 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_name = (yyvsp[-1].str_str);
    char *tbl_prop = (yyvsp[0].str_prp); tbl_prop += 5; /* jump over PROP= */
    mcr_chk_tbl_name(tbl_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"tbl_meta\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    /* note the underscore below */
    sprintf(g_buf, "  \"property\" : \"%s\" \n", tbl_prop);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null((yyvsp[-1].str_str));
    free_if_non_null((yyvsp[0].str_prp));
      }
#line 1499 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 9:
#line 242 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_name = (yyvsp[-2].str_str);
    char *fld_name = (yyvsp[0].str_str);
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
    free_if_non_null((yyvsp[-2].str_str));
    free_if_non_null((yyvsp[0].str_str));
      }
#line 1520 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 10:
#line 258 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_name = (yyvsp[-3].str_str);
    char *fld_name = (yyvsp[-1].str_str);
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
    free_if_non_null((yyvsp[-3].str_str));
    free_if_non_null((yyvsp[-1].str_str));
      }
#line 1541 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 11:
#line 274 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_name = (yyvsp[-3].str_str);
    char *fld_name = (yyvsp[-1].str_str);
    char *fld_prop = (yyvsp[0].str_prp); fld_prop += 5; /* jump over PROP= */
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
    free_if_non_null((yyvsp[-3].str_str));
    free_if_non_null((yyvsp[-1].str_str));
    free_if_non_null((yyvsp[0].str_prp));
      }
#line 1565 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 12:
#line 293 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_name = (yyvsp[-4].str_str);
    char *fld_name = (yyvsp[-2].str_str);
    char *fld_prop = (yyvsp[-1].str_prp); fld_prop += 5;
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
    free_if_non_null((yyvsp[-4].str_str));
    free_if_non_null((yyvsp[-2].str_str));
    free_if_non_null((yyvsp[-1].str_prp));
      }
#line 1593 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 13:
#line 316 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_name = (yyvsp[-3].str_str);
    char *fld_name = (yyvsp[-1].str_str);
    char *fld_prop = (yyvsp[0].str_prp);  fld_prop += 5;
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
    free_if_non_null((yyvsp[-3].str_str));
    free_if_non_null((yyvsp[-1].str_str));
    free_if_non_null((yyvsp[0].str_prp));
      }
#line 1619 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 14:
#line 337 "qgrammar.y" /* yacc.c:1646  */
    {
  char *tbl_name = (yyvsp[-3].str_str);
  char *op   = (yyvsp[-1].str_vrb); op   += 3; // Jump over OP=
  char *args = (yyvsp[0].str_arg); args += 5; // Jump over ARGS=
  mcr_chk_tbl_name(tbl_name);
  mcr_chk_add_tbl_op(op);
  strcat(g_op, "{ \n");
  strcat(g_op, "  \"verb\" : \"add_tbl\", \n");
  sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
  strcat(g_op, g_buf);
  sprintf(g_buf, "  \"ARGS\" : %s \n", args);
  strcat(g_op, g_buf);
  strcat(g_op, "} \n");
  free_if_non_null((yyvsp[-3].str_str));
  free_if_non_null((yyvsp[-1].str_vrb));
  free_if_non_null((yyvsp[0].str_arg));

}
#line 1642 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 15:
#line 355 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_name = (yyvsp[0].str_str);
    mcr_chk_tbl_name(tbl_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"del_tbl\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\" \n", tbl_name);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null((yyvsp[0].str_str));
      }
#line 1657 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 16:
#line 366 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_name = (yyvsp[-2].str_str);
    char *fld_name = (yyvsp[0].str_str);
    mcr_chk_tbl_name(tbl_name);
    mcr_chk_tbl_name(fld_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"del_fld\", \n");
    sprintf(g_buf, "  \"tbl\" : \"%s\", \n", tbl_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"fld\" : \"%s\" \n", fld_name);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null((yyvsp[-2].str_str));
    free_if_non_null((yyvsp[0].str_str));
      }
#line 1677 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 17:
#line 381 "qgrammar.y" /* yacc.c:1646  */
    {
    
    char *tbl_name = (yyvsp[-5].str_str);
    char *fld_name = (yyvsp[-3].str_str);
    char *op       = (yyvsp[-1].str_vrb); op   += 3; // jump over OP=
    char *args     = (yyvsp[0].str_arg); args += 5; // jump over ARGS=
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
    free_if_non_null((yyvsp[-5].str_str));
    free_if_non_null((yyvsp[-3].str_str));
    free_if_non_null((yyvsp[-1].str_vrb));
    free_if_non_null((yyvsp[0].str_arg));
      }
#line 1724 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 18:
#line 423 "qgrammar.y" /* yacc.c:1646  */
    {
  /* f1opf2 */
    
    char *tbl_name = (yyvsp[-7].str_str);
    char *f1_name  = (yyvsp[-5].str_str);
    char *op       = (yyvsp[-3].str_vrb); op   += 3; // jump over OP=
    char *f2_name  = (yyvsp[-2].str_str);
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
    free_if_non_null((yyvsp[-7].str_str));
    free_if_non_null((yyvsp[-5].str_str));
    free_if_non_null((yyvsp[-3].str_vrb));
    free_if_non_null((yyvsp[-2].str_str));
      }
#line 1765 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 19:
#line 459 "qgrammar.y" /* yacc.c:1646  */
    {

    char *op = (yyvsp[-4].str_vrb); op += 3; // jump over OP=
    char *tbl_name = (yyvsp[-3].str_str);
    char *fld_name = (yyvsp[-1].str_str);
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
    free_if_non_null((yyvsp[-4].str_vrb));
    free_if_non_null((yyvsp[-3].str_str));
    free_if_non_null((yyvsp[-1].str_str));
      }
#line 1804 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 20:
#line 493 "qgrammar.y" /* yacc.c:1646  */
    {

    char *op = (yyvsp[-4].str_vrb); op += 3; // jump over OP=
    char *fld_name = (yyvsp[-1].str_str);
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
    free_if_non_null((yyvsp[-4].str_vrb));
    free_if_non_null((yyvsp[-1].str_str));
      }
#line 1868 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 21:
#line 552 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_dst_name = (yyvsp[-2].str_str);
    char *tbl_src_name = (yyvsp[0].str_str);
    mcr_chk_tbl_name(tbl_dst_name);
    mcr_chk_tbl_name(tbl_src_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"app_tbl\", \n");
    sprintf(g_buf, "  \"tbl_dst\" : \"%s\", \n", tbl_dst_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"tbl_src\" : \"%s\" \n", tbl_src_name);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null((yyvsp[-2].str_str));
    free_if_non_null((yyvsp[0].str_str));
      }
#line 1888 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 22:
#line 567 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_dst_name = (yyvsp[-2].str_str);
    char *tbl_src_name = (yyvsp[0].str_str);
    mcr_chk_tbl_name(tbl_dst_name);
    mcr_chk_tbl_name(tbl_src_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"copy_tbl\", \n");
    sprintf(g_buf, "  \"tbl_dst\" : \"%s\", \n", tbl_dst_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"tbl_src\" : \"%s\" \n", tbl_src_name);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null((yyvsp[-2].str_str));
    free_if_non_null((yyvsp[0].str_str));
      }
#line 1908 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 23:
#line 582 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_dst_name = (yyvsp[-2].str_str);
    char *tbl_src_name = (yyvsp[0].str_str);
    mcr_chk_tbl_name(tbl_dst_name);
    mcr_chk_tbl_name(tbl_src_name);
    strcat(g_op, "{ \n");
    strcat(g_op, "  \"verb\" : \"rename_tbl\", \n");
    sprintf(g_buf, "  \"tbl_dst\" : \"%s\", \n", tbl_dst_name);
    strcat(g_op, g_buf);
    sprintf(g_buf, "  \"tbl_src\" : \"%s\" \n", tbl_src_name);
    strcat(g_op, g_buf);
    strcat(g_op, "} \n");
    free_if_non_null((yyvsp[-2].str_str));
    free_if_non_null((yyvsp[0].str_str));
      }
#line 1928 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 24:
#line 597 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_dst_name = (yyvsp[-6].str_str);
    char *fld_dst_name = (yyvsp[-4].str_str);
    char *tbl_src_name = (yyvsp[-2].str_str);
    char *fld_src_name = (yyvsp[0].str_str);
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
      free((yyvsp[-6].str_str));
      free((yyvsp[-4].str_str));
      free((yyvsp[-2].str_str));
      free((yyvsp[0].str_str));
      }
#line 1963 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 25:
#line 627 "qgrammar.y" /* yacc.c:1646  */
    {
    char *tbl_dst_name = (yyvsp[-6].str_str);
    char *fld_dst_name = (yyvsp[-4].str_str);
    char *tbl_src_name = (yyvsp[-2].str_str);
    char *fld_src_name = (yyvsp[0].str_str);
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
    free((yyvsp[-6].str_str));
    free((yyvsp[-4].str_str));
    free((yyvsp[-2].str_str));
    free((yyvsp[0].str_str));
  }
#line 2003 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 26:
#line 665 "qgrammar.y" /* yacc.c:1646  */
    {
  char *tbl_name = (yyvsp[-4].str_str);
  char *cfld_name = (yyvsp[-1].str_str);
  mcr_chk_tbl_name(tbl_name);
  mcr_chk_tbl_name(cfld_name);
  // zero_tbl(&g_tbl);
  strcpy(g_tbl.tbl, tbl_name);
  strcpy(g_tbl.where.cfld, cfld_name);
  g_tbl.where.RestrictionType = RESTRICT_CFLD;
}
#line 2018 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 27:
#line 676 "qgrammar.y" /* yacc.c:1646  */
    {
  int status = 0;
  int64_t lb, ub;
  char *tbl_name = (yyvsp[-5].str_str);
  char *str_lb   = (yyvsp[-2].str_int);
  char *str_ub   = (yyvsp[-1].str_int);
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
#line 2057 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 28:
#line 711 "qgrammar.y" /* yacc.c:1646  */
    {
  char *tbl_name = (yyvsp[-7].str_str);
  char *ctbl   = (yyvsp[-4].str_str);
  char *lbfld = (yyvsp[-3].str_str);
  char *ubfld = (yyvsp[-2].str_str);
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
#line 2078 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 29:
#line 729 "qgrammar.y" /* yacc.c:1646  */
    {
  for ( int i = 0; i < MAX_LEN_Q_ARGS+1; i++ ) { g_args[i] = '\0'; }
}
#line 2086 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 30:
#line 734 "qgrammar.y" /* yacc.c:1646  */
    {
  int len = strlen((yyvsp[0].str_arg));
  if ( ( len <= 5 ) || ( len >= MAX_LEN_Q_ARGS+5 ) ) { 
    sprintf(g_err, "Arguments are too long. Fishy...");
    WHEREAMI; return -1;
  }
  strcpy(g_args, (yyvsp[0].str_arg)+5); 
}
#line 2099 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 31:
#line 743 "qgrammar.y" /* yacc.c:1646  */
    {
  int len = 0;
  for ( char *cptr = (yyvsp[0].str_int); *cptr != '\0'; cptr++, len++ ) { 
    if ( len >= MAX_LEN_Q_VALUE ) {
      strcpy(g_err, "Value provided is too long. First 32 chars are");
      strncat(g_err, (yyvsp[0].str_int), 32);
      WHEREAMI;
      return -1;
    }
    g_val[len] = *cptr;
  }
}
#line 2116 "qgrammar.tab.c" /* yacc.c:1646  */
    break;

  case 32:
#line 755 "qgrammar.y" /* yacc.c:1646  */
    {
  int len = 0;
  for ( char *cptr = (yyvsp[0].str_str); *cptr != '\0'; cptr++, len++ ) { 
    if ( len >= MAX_LEN_Q_VALUE ) {
      strcpy(g_err, "Value provided is too long. First 32 chars are");
      strncat(g_err, (yyvsp[0].str_str), 32);
      WHEREAMI;
      return -1;
    }
    g_val[len] = *cptr;
  }
}
#line 2133 "qgrammar.tab.c" /* yacc.c:1646  */
    break;


#line 2137 "qgrammar.tab.c" /* yacc.c:1646  */
      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYEMPTY : YYTRANSLATE (yychar);

  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
# define YYSYNTAX_ERROR yysyntax_error (&yymsg_alloc, &yymsg, \
                                        yyssp, yytoken)
      {
        char const *yymsgp = YY_("syntax error");
        int yysyntax_error_status;
        yysyntax_error_status = YYSYNTAX_ERROR;
        if (yysyntax_error_status == 0)
          yymsgp = yymsg;
        else if (yysyntax_error_status == 1)
          {
            if (yymsg != yymsgbuf)
              YYSTACK_FREE (yymsg);
            yymsg = (char *) YYSTACK_ALLOC (yymsg_alloc);
            if (!yymsg)
              {
                yymsg = yymsgbuf;
                yymsg_alloc = sizeof yymsgbuf;
                yysyntax_error_status = 2;
              }
            else
              {
                yysyntax_error_status = YYSYNTAX_ERROR;
                yymsgp = yymsg;
              }
          }
        yyerror (yymsgp);
        if (yysyntax_error_status == 2)
          goto yyexhaustedlab;
      }
# undef YYSYNTAX_ERROR
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYTERROR;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#if !defined yyoverflow || YYERROR_VERBOSE
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  yystos[*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
BYE: return yyresult;
}
#line 770 "qgrammar.y" /* yacc.c:1906  */

int yyerror(
    const char *s
    ) 
{
  sprintf(g_err, "EEK, parse error!  Message: [%s]\n", s);
  WHEREAMI;
  return -1;
}
