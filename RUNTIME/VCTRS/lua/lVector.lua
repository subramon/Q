local ffi               = require 'ffi'
local cVector = ffi.load("libvctrs.so")
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
extern uint32_t
chnk_cnt(
    void
    );
extern int
chnk_is(
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    bool *ptr_is_found,
    uint32_t *ptr_where_found
    );
extern void *
mk_chnk_hmap(
    void
    );
extern void *
mk_vctr_hmap(
    void
    );
extern int
vctr_add1(
    qtype_t qtype,
    uint32_t in_chnk_size,
    uint32_t *ptr_uqid
    );
extern bool
vctr_is(
    uint32_t uqid
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
vctr_is_eov(
    uint32_t vctr_uqid,
    bool *ptr_is_eov
    );
extern int
vctr_is(
    uint32_t v,
    bool *ptr_is_found,
    uint32_t *ptr_where_found
    );
extern int
vctr_set_name(
    const char * const name,
    uint32_t uqid
    );
extern char *
vctr_get_name(
    uint32_t uqid
    );
extern uint32_t
vctr_new_uqid(
    void
    );
extern int
vctr_num_chunks(
    uint32_t vctr_uqid,
    uint32_t *ptr_num_chunks
    );
extern int
vctr_num_elements(
    uint32_t vctr_uqid,
    uint32_t *ptr_num_elements
    );
extern int
vctr_put_chunk(
    uint32_t vctr_uqid,
    char **ptr_X, // [vctr.chnk_size]
    bool is_stealable,
    uint32_t n // number of elements 1 <= n <= vctr.chnk_size
    );
extern int
vctr_put(
    uint32_t uqid,
    char *X,
    uint32_t n // number of elements
    );
]])
--====================================
local uqid -- This defines the vector - super important 
local lVector = {}
lVector.__index = lVector

local setmetatable = require '__gc'
local mt = {
   __call = function (cls, ...)
      return cls.new(...)
   end,
   __gc = function() 
     print("Calling gc ")
     local is_found  = ffi.new("bool[?]", 1)
     is_found = ffi.cast("bool *", is_found)
    local status = cVector.vctr_del(self.uqid, is_found)
    if ( status ~= 0 ) then print("Error in gc") end 
    -- print("DONE Calling gc ")
  end
}
setmetatable(lVector, mt)

-- register_type(lVector, "lVector")

function lVector:check()
  assert(cVector.vctr_chk(self._base_vec))
  if ( self._nn_vec ) then 
    assert(cVector.vctr_chk(self._nn_vec))
  end 
  return true
end

function lVector:num_chunks()
  local num_chunks = fff.new("uint32_t[?]", 1)
  num_chunks = ffi.cast("uint32_t *", num_chunks) 
  local status = cVector.num_chunks(self.uqid, num_chunks)
  assert(status == 0)
  return num_chunks
end

function lVector:num_elements()
  local num_elements = fff.new("uint32_t[?]", 1)
  num_elements = ffi.cast("uint32_t *", num_elements) 
  local status = cVector.num_elements(self.uqid, num_elements)
  assert(status == 0)
  return num_elements
end

function lVector:get_name()
  local name = fff.new("char *[?]", 1)
  name = ffi.cast("char **", 1) 
  local name = cVector.get_name(self.uqid)
  return name
end

function lVector:is_eov()
  local is_eov = fff.new("bool[?]", 1)
  is_eov = ffi.cast("bool *", is_eov) 
  local status = cVector.is_eov(self.uqid, is_eov)
  assert(status == 0)
  return num_elements
end
function lVector.new(args)
  local vector = setmetatable({}, lVector)
  vector.meta = {} -- for meta data stored in vector
  assert(type(args) == "table")
  local str_qtype = assert(args.qtype)
  assert(type(str_qtype) == "string")
  if ( str_qtype == "F4" ) then 
    qtype = 7;
  end
  local l_uqid = ffi.new("uint32_t[?]", 1)
  l_uqid = ffi.cast("uint32_t *", l_uqid);
  local status = cVector.vctr_add1(qtype, 0, l_uqid);
  assert(status == 0)
  vector.uqid = l_uqid; -- IMPORTANT 
  vector.siblings = {} -- no conjoined vectors
  return vector
end
return lVector
