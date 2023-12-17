#ifndef __QTYPES_H
#define __QTYPES_H
//START_FOR_CDEF
typedef uint16_t bfloat16; 
//  TODO P2 This should be uncommented #include "custom1.h" // for CUSTOM1
typedef struct _custom1_t {
  bfloat16 intercept;
  bfloat16 goodfriday;
  bfloat16 easter;
  bfloat16 mardigras;
  bfloat16 memorialday;
  bfloat16 mothersday_minus;
  bfloat16 mothersday;
  bfloat16 presidentsday;
  bfloat16 superbowl_minus;
  bfloat16 superbowl;
  bfloat16 thanksgiving;
  bfloat16 valentines;
  bfloat16 stpatricks;
  bfloat16 cincodemayo;
  bfloat16 julyfourth;
  bfloat16 halloween;
  bfloat16 christmas_minus;
  bfloat16 christmas;
  bfloat16 newyearsday;
  bfloat16 t_o_y;
  bfloat16 n_week;
  bfloat16 time_band;
  bfloat16 btcs_value;
  bfloat16 sls_unit_q_L1;
  bfloat16 sls_unit_q_L2;
  bfloat16 sls_unit_q_L3;
  bfloat16 sls_unit_q_L4;
  bfloat16 sls_unit_q_L5;
  bfloat16 baseprice;
  bfloat16 offerprice;
  bfloat16 baseprice_lift;
  bfloat16 promo_lift;
  uint64_t bmask;
} custom1_t;

typedef enum { 
  Q0, // mixed  must be first one 

  B1, // boolean as a bit
  BL, // boolean as a bool

  I1,
  I2,
  I4,
  I8,

  F2,
  F4,
  F8,

  UI1,
  UI2,
  UI4,
  UI8,

  SC,  // constant length strings
  SV,  // variable length strings
  TM,  // time struct  tm_t
  TM1, // time struct  tm_t

  CUSTOM1, // for MG experiment 

  NUM_QTYPES // must be last one 
} qtype_t;
// STOP extract_for_qtypes.tex
typedef struct _tm_t {
  int16_t tm_year;	/* Year	- 1900. */
  int8_t tm_mon;	/* Month.	[0-11] */
  int8_t tm_mday;	/* Day.		[1-31] */
  int8_t tm_hour;	/* Hours.	[0-23] */
  // int8_t tm_min;	/* Minutes.	[0-59] */
  // int8_t tm_sec;	/* Seconds.	[0-60] (1 leap second) */
  int8_t tm_wday;	/* Day of week.	[0-6] */
  int16_t tm_yday;	/* Days in year.[0-365]	*/

  /* Not being used 
  int tm_isdst;			// DST.		[-1/0/1]
# ifdef	__USE_MISC
  long int tm_gmtoff;		// Seconds east of UTC.  
  const char *tm_zone;		// Timezone abbreviation.  
# else
  long int __tm_gmtoff;		// Seconds east of UTC.  
  const char *__tm_zone;	// Timezone abbreviation.  
# endif
  */
} tm_t;
//STOP_FOR_CDEF
extern qtype_t
get_tm_qtype(
    const char * const fld
    );
extern int
t_assign(
    struct tm *dst, 
    tm_t *src
    );
extern int
get_width_qtype(
    const char * const str_qtype
    );
extern int
get_width_c_qtype(
      qtype_t qtype
    );
extern qtype_t
get_c_qtype(
    const char *const str_qtype
    );
extern const char *
get_str_qtype(
    qtype_t qtype
    );
extern const char *
str_qtype_to_str_ctype(
    const char * const str_qtype
    );
extern bool
is_qtype(
    const char *const str_qtype
    );
extern const char *
str_qtype_to_str_ispctype(
    const char * const str_qtype
    );
extern bfloat16
F4_to_F2(
    float x
    );
extern float
F2_to_F4(
    bfloat16 x
    );
#endif // __QTYPES_H
