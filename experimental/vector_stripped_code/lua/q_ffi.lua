local ffi = require "ffi"
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
void * malloc(size_t size);
void free(void *ptr);
FILE *fopen(const char *path, const char *mode);
int fclose(FILE *stream);
int fwrite(void *Buffer,int Size,int Count,FILE *ptr);
int fflush(FILE *stream);
]])

-- TODO: Put this back later ffi.new = nil 

ffi.malloc = function(n, free_func)
   assert(n > 0, "Cannot malloc 0 or less bytes")
   local c_mem = nil
   if free_func == nil then
      c_mem = assert(ffi.gc(ffi.C.malloc(n), ffi.C.free))
   else -- TODO Review with Indrajeet
      c_mem = assert(ffi.gc(ffi.C.malloc(n), free_func))
   end
   return c_mem
end

ffi.memset = function(buffer, value, size)
   assert( buffer ~= nil, "Buffer cannot be nil")
   assert(size > 0, "Cannot memset 0 or less bytes")
   assert(ffi.C.memset(buffer, value, size), "ffi memset failed")
end

ffi.memcpy = function(dest, src, size)
   assert( dest ~= nil, " destination buffer cannot be nil")
   assert( src ~= nil, " source buffer cannot be nil")
   assert(size > 0, "Cannot memset 0 or less bytes")
   assert(ffi.C.memcpy(dest, src, size), "ffi memcpy failed")
end

return ffi
