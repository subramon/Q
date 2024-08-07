local ffi = require 'ffi'
local L1 = ffi.load("../../../TMPL_FIX_HASHMAP/VCTR_HMAP/libhmap_VCTR.so")
local L2 = ffi.load("../../../RUNTIME/VCTRS/src/libvctrs.so")
ffi.cdef([[
typedef uint16_t bfloat16; 
typedef enum { 
  Q0, // mixed  must be first one 
  BL, // boolean (currently stored as I1)

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
  TM1, // time struct  tm_t
  HL,  // holiday bit mask 
  NUM_QTYPES // must be last one 
} qtype_t;
typedef struct _tm_t {
  int8_t tm_year;	/* Year	- 1900. TODO P4 Watch out for 2027!  */
  int8_t tm_mon;	/* Month.	[0-11] */
  int8_t tm_mday;	/* Day.		[1-31] */
  int8_t tm_hour;	/* Hours.	[0-23] */
  int8_t tm_min;	/* Minutes.	[0-59] */
  int8_t tm_sec;	/* Seconds.	[0-60] (1 leap second) */
  // UNUSED int8_t tm_wday;	/* Day of week.	[0-6] */
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
extern int
vctr_add1(
    qtype_t qtype,
    uint32_t *ptr_uqid
    );
extern uint32_t
vctr_cnt(
    void
    );
extern int
vctr_del(
    uint32_t uqid,
    bool *ptr_is_found
    );
extern int
vctr_is(
    uint32_t v,
    bool *ptr_is_found,
    uint32_t *ptr_where_found
    );
extern uint32_t
vctr_new_uqid(
    void
    );
    ]])
local n = L2.vctr_cnt()
assert(n == 0)

local uqid = ffi.new("uint32_t[?]", 1)
uqid = ffi.cast("uint32_t *", uqid)
local status = L2.vctr_add1(4, uqid)
assert(status == 0)
local n = L2.vctr_cnt()
assert(n == 1)
print("uqid = " .. tonumber(uqid[0]))


print("All done")

