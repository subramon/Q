local ffi = require "ffi"
local cmem = require'libcmem'
ffi.cdef([[
void *memset(void *s, int c, size_t n);
void *memcpy(void *dest, const void *src, size_t n);
size_t strlen(const char *str);
typedef struct {
   char *fpos;
   void *base;
   unsigned short handle;
   short flags;
   short unget;
   unsigned long alloc;
   unsigned short buffincrement;
} FILE;
  struct drand48_data
  {
    unsigned short int __x[3];	/* Current state.  */
    unsigned short int __old_x[3]; /* Old state.  */
    unsigned short int __c;	/* Additive const. in congruential formula.  */
    unsigned short int __init;	/* Flag for initializing.  */
    __extension__ unsigned long long int __a;	/* Factor in congruential
						   formula.  */
  };
void * malloc(size_t size);
void free(void *ptr);
typedef struct tm
{
  int tm_sec;			/* Seconds.	[0-60] (1 leap second) */
  int tm_min;			/* Minutes.	[0-59] */
  int tm_hour;			/* Hours.	[0-23] */
  int tm_mday;			/* Day.		[1-31] */
  int tm_mon;			/* Month.	[0-11] */
  int tm_year;			/* Year	- 1900.  */
  int tm_wday;			/* Day of week.	[0-6] */
  int tm_yday;			/* Days in year.[0-365]	*/
  int tm_isdst;			/* DST.		[-1/0/1]*/

  long int __tm_gmtoff;		/* Seconds east of UTC.  */
  const char *__tm_zone;	/* Timezone abbreviation.  */
} TM ; 
   ]])
   --[[
   --NOTE: I gave a name TM to the struct tm because LuaFFI complained
--]]

-- TODO: Put this back later ffi.new = nil
-- That's because we want malloc to ONLY go through C API
local t_ffi = {}
t_ffi.malloc = function(n, free_func)
   assert(nil, "Not supported, please use libcmem")
   assert(n > 0, "Cannot malloc 0 or less bytes")
   local c_mem = nil
   local old = false -- TODO P0 Fix this the right way
   if old then
      if free_func == nil then
         c_mem = assert(ffi.gc(ffi.C.malloc(n), ffi.C.free))
      else -- TODO Review with Indrajeet
         c_mem = assert(ffi.gc(ffi.C.malloc(n), free_func))
      end
   else
      c_mem = cmem.new(n)
   end
   return c_mem
end

t_ffi.memset = function(buffer, value, size)
   assert( buffer ~= nil, "Buffer cannot be nil")
   assert(size > 0, "Cannot memset 0 or less bytes")
   assert(ffi.C.memset(buffer, value, size), "ffi memset failed")
end

t_ffi.memcpy = function(dest, src, size)
   assert( dest ~= nil, " destination buffer cannot be nil")
   assert( src ~= nil, " source buffer cannot be nil")
   assert(size > 0, "Cannot memset 0 or less bytes")
   assert(ffi.C.memcpy(dest, src, size), "ffi memcpy failed")
end
local ffi_mt = {
   __newindex = function(self, key, value)
      error("Cannot set new value in ffi")
   end,
   __index = function(self, key)
      if t_ffi[key] ~= nil then
         return t_ffi[key]
      end
      return ffi[key]
   end
}
local t = {}
setmetatable(t,ffi_mt)
return t
