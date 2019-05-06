local ffi = require 'ffi'
ffi.cdef([[
  typedef struct _mmap_struct {
    void* ptr_mmapped_file;
    size_t file_size;
    int status;
  } mmap_struct;
  ]])
return function()
  require 'globals'
  local plfile = require 'pl.file'
  local plpath = require 'pl.path'
  assert(g_q_core_h, "Core includes not set")
  assert(plpath.isfile(g_q_core_h), "File not found " .. g_q_core_h)
  local str = assert(plfile.read(g_q_core_h),"File empty " .. g_q_core_h) 
  --================================
  local ffi = require 'ffi'
  ffi.cdef([[
  void * malloc(size_t size);
  void free(void *ptr);

  ]])
  -- TODO Consider better way of mmap_struct showing up
  ffi.cdef(str)
  return ffi.load("q_core")
end
