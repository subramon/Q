#define MAX_LEN_Q_ARGS 1023
#define MAX_NUM_FLDS_IN_LIST 32
#define MAX_LEN_PARSED_JSON 1023
#define MAX_LEN_Q_COMMAND   1023
#define MAX_LEN_Q_ERROR     1023
#define MAX_LEN_Q_VALUE     1023

#define RESTRICT_CFLD 100
#define RESTRICT_RANGE 200
#define RESTRICT_RANGE_SET 300
typedef struct _wheretype {
  int RestrictionType;
  char cfld[32];
  uint64_t lb;
  uint64_t ub;
  char  ctbl[32];
  char lbfld[32];
  char ubfld[32];
  } wheretype;

typedef struct _tblytpe {
  char tbl[32];
  wheretype where;
  } TBLTYPE;

