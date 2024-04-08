#ifndef __QTYPES_H
#define __QTYPES_H
typedef uint32_t holiday_bmask_t; // this comes from RBC. Should not be here
                                  // RBC code needs to be cleaned up
//START_FOR_CDEF
typedef uint16_t bfloat16; 
// TODO P3: At some stage, names should refer to to bits instead of bytes
// In other words, instead of I8 it should be I64
typedef enum { 
  Q0, // mixed  must be first one 

  B1, // boolean as a bit
  BL, // boolean as a bool

  I1,
  I2,
  I4,
  I8,
  I16,

  F2,
  F4,
  F8,

  UI1,
  UI2,
  UI4,
  UI8,
  UI16,

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
